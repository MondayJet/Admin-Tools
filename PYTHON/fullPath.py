import os
folder_list = os.listdir("C:\\Users\\UserName\\Desktop")
Dir = "Desktop"

for name in folder_list:
    fullpath = os.path.join(Dir, name)
    if os.path.isdir(fullpath):
        print(f"{fullpath} is directory")
    else:
        print(f"{fullpath} is a file")