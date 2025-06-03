import os

def rename_files_in_folder(folder_path):
    files = sorted(os.listdir(folder_path))
    # Only process PNG files
    files = [f for f in files if f.endswith('.png')]

    topic = 1
    unit = 1
    lesson = 1
    slide = 1

    for filename in files:
        new_filename = f"{topic:02d}_{unit:02d}_{lesson:02d}_{slide:02d}.png"
        os.rename(os.path.join(folder_path, filename), os.path.join(folder_path, new_filename))

        slide += 1
        if slide > 5:
            slide = 1
            lesson += 1
        if lesson > 5:
            lesson = 1
            unit += 1

    return "Files renamed successfully according to the naming scheme."

rename_files_in_folder('C:\\Users\\tommy\\Documents\\GitHub\\FrontEnd\\content\\final_slides')
