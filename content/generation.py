import json
import os
from typing import List
from pydantic import BaseModel, ValidationError
from PIL import Image, ImageDraw, ImageFont, ImageColor
from diffusers import DiffusionPipeline
import re

import ollama  # Using the Ollama Python library

# Model representing a single slide with its textual content and corresponding image description
class Slide(BaseModel):
    content: str
    image: str

# Container model for an array of Slide objects
class SlideArr(BaseModel):
    slides: List[Slide]

# Function to call Ollama's API locally and get a list of Slide objects for a given topic,
# using grammar constraining controlled by our Pydantic model’s JSON schema.
def generate_slide_content_with_ollama(topic: str, num_slides: int = 5) -> SlideArr:
    prompt = f'''
You are an expert educator creating educational slides. For the topic "{topic}", generate exactly {num_slides} slides.
Each slide must be a JSON object with two keys:
  - "content": 3~5 sentences of text in layman's terms all undercase besides proper nouns explaining the topic in an engaging and easy-to-understand manner.
  - "image": a specific stable diffusion prompt that describes an image to complement the slide's content. this prompt should be detailed and include:
        - specific elements (for example, names of objects like portraits, paintings, diagrams, etc.)
        - a clear description of the mood and visual style.
    the default image prompt should be for a vertical 4:3 image in a minimalistic and aesthetic style. for example:
        "portrait of a serene figure in minimalist style, vertical 4:3 composition, soft pastel colors, clean lines, calm aesthetic background"
    only diverge from this default if the topic explicitly mentions a different art style or artist (e.g., impressionist, cubist, or in the style of van gogh).
    
Please format your output as valid JSON that strictly follows this schema.

{SlideArr.model_json_schema()}
'''

    # Call Ollama's chat function while passing the Pydantic JSON schema for grammar constraining.
    response = ollama.chat(
        messages=[{'role': 'user', 'content': prompt}],
        model="deepseek-r1:8b",
        format=SlideArr.model_json_schema()
    )

    # Assume the response is available in response.message.content
    response_text = response.message.content.strip()

    try:
        # Validate and parse the JSON output using Pydantic's model_validate_json method.
        slide_arr = SlideArr.model_validate_json(response_text)
        if len(slide_arr.slides) != num_slides:
            raise ValueError(f"Expected {num_slides} slides, but got {len(slide_arr.slides)}")
        print("Successfully validated SlideArr:", slide_arr)
        return slide_arr
    except (json.JSONDecodeError, ValidationError, ValueError) as e:
        print("Error parsing or validating JSON response from Ollama:", e)
        return SlideArr(slides=[])

# Function to generate images using Stable Diffusion based on descriptions provided by Ollama
def generate_images_with_stable_diffusion(slides: List[Slide], output_folder: str) -> List[str]:
    os.makedirs(output_folder, exist_ok=True)

    # Load DreamShaper model for Stable Diffusion
    pipe = DiffusionPipeline.from_pretrained("Lykon/DreamShaper")
    pipe.to("cuda")  # Use GPU if available

    generated_image_paths = []

    for idx, slide in enumerate(slides):
        prompt = slide.image
        print(f"Generating image for slide {idx + 1}: {prompt}")

        # Generate the image based on the prompt
        image = pipe(prompt).images[0]

        # Save the image to the output folder with a unique name per slide
        file_name = f"image_{idx + 1}.png"
        file_path = os.path.join(output_folder, file_name)
        image.save(file_path)
        generated_image_paths.append(file_path)

    return generated_image_paths

# Wrap text to fit within a given width
def wrap_text(text: str, font: ImageFont.ImageFont, max_width: int, draw: ImageDraw.ImageDraw) -> List[str]:
    words = text.split()
    lines = []
    current_line = []

    for word in words:
        test_line = ' '.join(current_line + [word])
        width = draw.textlength(test_line, font=font)
        if width <= max_width:
            current_line.append(word)
        else:
            lines.append(' '.join(current_line))
            current_line = [word]

    if current_line:
        lines.append(' '.join(current_line))

    return lines

# Justify text horizontally in a simple way
def justify_text_simple(draw: ImageDraw.ImageDraw, line: str, font: ImageFont.ImageFont, max_width: int) -> List[tuple]:
    words = line.split()
    if len(words) == 1:
        return [(words[0], 0)]

    words_length = sum(draw.textlength(word, font=font) for word in words)
    space_length = (max_width - words_length) / (len(words) - 1)

    x_positions = []
    x_cursor = 0
    for word in words:
        x_positions.append((word, x_cursor))
        x_cursor += draw.textlength(word, font=font) + space_length

    return x_positions

def justify_text_centered(draw: ImageDraw.ImageDraw, line: str, font: ImageFont.ImageFont, max_width: int, canvas_width: int) -> List[tuple]:
    """
    Justifies a single line of text to fit within max_width and centers it on the canvas.
    Returns a list of (word, x_position) pairs for drawing.
    """
    words = line.split()
    if len(words) == 1:
        # Single-word lines are centered directly
        word_width = draw.textlength(words[0], font=font)
        x_start = (canvas_width - word_width) // 2
        return [(words[0], x_start)]

    # Calculate total width of all words and space distribution
    words_length = sum(draw.textlength(word, font=font) for word in words)
    space_length = (max_width - words_length) / (len(words) - 1)

    # Calculate starting position for centering
    x_start = (canvas_width - max_width) // 2

    # Distribute spaces evenly between words
    x_positions = []
    x_cursor = x_start
    for word in words:
        x_positions.append((word, x_cursor))
        x_cursor += draw.textlength(word, font=font) + space_length

    return x_positions

# Dynamically adjust font size to fit within bounds
def adjust_font_size_to_fit(text: str, font_path: str, max_width: int, max_height: int, draw: ImageDraw.ImageDraw) -> ImageFont.ImageFont:
    font_size = 10
    while True:
        font = ImageFont.truetype(font_path, size=font_size)
        wrapped_lines = wrap_text(text, font, max_width, draw)
        total_height = sum(font.getbbox(line)[3] for line in wrapped_lines)

        if total_height > max_height or any(draw.textlength(line, font=font) > max_width for line in wrapped_lines):
            break
        font_size += 1

    return ImageFont.truetype(font_path, size=font_size - 1)
def sanitize_path(path: str) -> str:
    """
    Convert backslashes in a file path to forward slashes for compatibility with Python.
    """
    return path.replace("\\", "/")

# Create final slides using the generated slide content and corresponding images.
def create_final_slides_from_slides(slides: List[Slide], slide_image_paths: List[str],
                                    unit_title: str, week_title: str, lesson_topic: str,
                                    output_folder: str):
    os.makedirs(output_folder, exist_ok=True)

    # Define canvas and layout sizes
    canvas_width, canvas_height = 1080, 1920
    image_side = 700
    text_area_height = 600

    # Define colors
    background_color = "#F9F6EF"
    text_color = "#282828"

    # Load fonts (fallback to default if unavailable)
    title_font_path = "content/Aesthet-Regular.otf"
    body_font_path = "content/Aesthet-Regular.otf"
    
    # For each generated slide (each slide object corresponds to one final slide)
    for idx, slide in enumerate(slides):
        try:
            img_path = slide_image_paths[idx]

            # Open and resize the image proportionally
            img = Image.open(img_path).convert("RGB")
            img_aspect_ratio = img.width / img.height
            new_height = image_side
            new_width = int(new_height * img_aspect_ratio)
            if new_width > canvas_width:
                new_width = canvas_width
                new_height = int(new_width / img_aspect_ratio)
            img = img.resize((new_width, new_height), Image.Resampling.LANCZOS)

            # Create a blank canvas with background color
            canvas = Image.new("RGB", (canvas_width, canvas_height), ImageColor.getcolor(background_color, "RGB"))
            draw = ImageDraw.Draw(canvas)

            # Draw the lesson topic as the title at the top of the slide
            adjusted_title_font = adjust_font_size_to_fit(week_title,
                                                          title_font_path,
                                                          max_width=new_width,
                                                          max_height=150,
                                                          draw=draw)
            wrapped_title_lines = wrap_text(week_title, adjusted_title_font, new_width, draw)
            title_y_start = 200
            for line in wrapped_title_lines:
                justified_title_positions = justify_text_centered(draw, line, adjusted_title_font, new_width, canvas_width)
                for word, x_position in justified_title_positions:
                    draw.text((x_position, title_y_start),
                              word,
                              fill=ImageColor.getcolor(text_color, "RGB"),
                              font=adjusted_title_font)
                title_y_start += adjusted_title_font.getbbox(line)[3] + 10

            # Paste the resized image below the title
            image_x_start = (canvas_width - new_width) // 2
            image_y_start = title_y_start + 50
            canvas.paste(img, (image_x_start, image_y_start))

            # Draw the slide content (from the Slide object's "content" property) below the image
            adjusted_body_font = adjust_font_size_to_fit(slide.content,
                                                         body_font_path,
                                                         max_width=new_width,
                                                         max_height=text_area_height,
                                                         draw=draw)
            wrapped_body_lines = wrap_text(slide.content, adjusted_body_font, new_width, draw)
            body_y_start = image_y_start + new_height + 50
            for line in wrapped_body_lines:
                justified_body_positions = justify_text_simple(draw, line, adjusted_body_font, new_width)
                x_offset_start_body = (canvas_width - new_width) // 2
                for word, x_position in justified_body_positions:
                    draw.text((x_offset_start_body + x_position, body_y_start),
                              word,
                              fill=ImageColor.getcolor(text_color, "RGB"),
                              font=adjusted_body_font)
                body_y_start += adjusted_body_font.getbbox(line)[3] + 10

            # Save final composed slide; use unit, week, and lesson topic in the filename.
            unit_title = re.sub(r'[^a-zA-Z0-9\s]', '', unit_title)
            week_title_temp = re.sub(r'[^a-zA-Z0-9\s]', '', week_title)
            safe_lesson_topic = re.sub(r'[^a-zA-Z0-9\s]', '', lesson_topic)
            final_slide_name = f"{unit_title}_{week_title_temp}_{safe_lesson_topic}_slide_{idx + 1}.png"
            final_slide_path = sanitize_path(os.path.join(output_folder, final_slide_name))
            canvas.save(final_slide_path)
            print(f"Final slide saved at {final_slide_path}")

        except Exception as e:
            print(f"Error processing slide {idx + 1} for lesson '{lesson_topic}': {e}")

# Main function to execute the pipeline with the curriculum JSON input.
if __name__ == "__main__":
    # Path to the curriculum JSON file (should contain a nested dictionary like {unit_title: {week_title: [lesson_topic, ...], ...}, ...})
    json_file_path = "content/art_curriculum.json"
    images_folder_base = "images"
    output_folder_path = "final_slides"

    os.makedirs(images_folder_base, exist_ok=True)
    os.makedirs(output_folder_path, exist_ok=True)

    # Load curriculum from JSON file
    with open(json_file_path, 'r') as f:
        curriculum = json.load(f)

    # For each unit and week in the curriculum, iterate over lessons.
    # For each lesson topic, generate slide content using Ollama,
    # then generate images via Stable Diffusion,
    # and finally compose and save the final slides using the generated text and images.
    for unit_title, weeks in curriculum.items():
        for week_title, lessons in weeks.items():
            for lesson in lessons:
                print(f"\nProcessing lesson: {lesson}")
                # Generate the slide content for this lesson topic using Ollama
                slide_arr = generate_slide_content_with_ollama(lesson, num_slides=5)
                if not slide_arr.slides:
                    print(f"Skipping lesson '{lesson}' due to error in generating slide content.")
                    continue

                # Create a unique folder for images for this lesson
                safe_unit_title = re.sub(r'[^a-zA-Z0-9\s]', '', unit_title)
                safe_week_title = re.sub(r'[^a-zA-Z0-9\s]', '', week_title)
                safe_lesson_topic = re.sub(r'[^a-zA-Z0-9\s]', '', lesson)
                lesson_image_folder = os.path.join(images_folder_base, f"{safe_unit_title}_{safe_week_title}_{safe_lesson_topic}")
                os.makedirs(lesson_image_folder, exist_ok=True)

                # Generate images using Stable Diffusion based on the image prompts from slide objects
                slide_image_paths = generate_images_with_stable_diffusion(slide_arr.slides, lesson_image_folder)

                # Create the final composed slides using the generated slide content and corresponding images
                create_final_slides_from_slides(slide_arr.slides, slide_image_paths,
                                                unit_title, week_title, lesson,
                                                output_folder_path)
