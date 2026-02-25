# Cook-App Flask Backend
## Backend Installation and Setup

1. Clone the respository

    - Download the GitHub cli tool: ```https://cli.github.com/```
    - Run the command ```gh auth login``` and follow instructions (choose https)
    - Once authenticated, run the command: ```gh repo clone SETaP-Team-6C/Cook-App```
    - Navigate to the directory with ```cd Cook-App```
    - You have now cloned the repository!


2. Install Python Dependencies
    - Go to the Cook-App directory in the terminal and navigate to the backend with ```cd backend```
    - run ```pip install -r requirements.txt```, this will install flask to your python install

3. Run Flask
    - Go into the ```Cook-App/backend/main``` directory
    - Run

        - Windows: ```python -m flask --app app run```
        - Linux: ```python3 -m flask --app app run```
   - You should see the server run in the terminal
   - Access by using a web browser and going to ```localhost:5000```


## Backend Structure Guide
```
Backend (This Directory)
 
| 
|   README.md (This file)
|
+---database
|       schema.sql
|       test_data.sql (Data for testing purposes, the unit tests rely on this data)
|
+---main (All of the code for the backend)
|   |   app.py (Entry point)
|   |   database.db (Automatically created by database.py if this does not exist. Pulls data from the '/database' folder)
|   |   database.py (Gives you a convenient database object to use)
|   |   paths.py (Gives you a path to '/backend' and '/backend/main' which works universally)
|   |   requirements.txt (Python dependencies)
|   |   __init__.py (Tells python to make this a package)
|   |
|   +---authentication
|   |   |   routes.py
|   |   |   __init__.py
|   |   |
|   |   +---sql
|   |   |       get_user.sql
|   |   |
|   |
|   +---index
|   |   |   routes.py
|   |   |   __init__.py
|   |   |
|   |
|   +---recipe
|   |   |   routes.py
|   |   |   __init__.py
|   |   |
|   |   +---sql
|   |   |       get_recipes.sql
|   |
|
+---test (Unit Tests)
|   |   authentication.py
|   |   conftest.py
|   |   __init__.py
|   |
     
```
