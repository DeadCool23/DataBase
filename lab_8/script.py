import libs.directory as dir
from libs.sleep import delay
from libs.gen_funcs.gen_filename import gen_filename 
from libs.gen_funcs.gen_user import TABLENAME, generate_and_save_users_to_csv


if "__main__" == __name__:
    filenum = 1
    users_num = 5
    dir.create_dir(dir.DATA_DIR)
    while True:
        filename = gen_filename(TABLENAME, filenum)
        generate_and_save_users_to_csv(f"{dir.DATA_DIR}/{filename}", users_num)
        print(f"Generated file: {filename} with {users_num} users")
        filenum += 1
        delay()
