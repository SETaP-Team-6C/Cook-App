# Cook-App
A mobile app that teaches people how to cook.


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
    - Go into the ```Cook-App/backend``` directory
    - Run

        - Windows: ```python -m flask --app app run```
        - Linux: ```python3 -m flask --app app run```
   - You should see the server run in the terminal
   - Access by using a web browser and going to ```localhost:5000```


## Backend Structure

* [backend](./backend)

   * [__init__.py](./backend/__init__.py) (Tells python that this directory is a package)

   * [app.py](./backend/app.py) (Entry Point)

   * [database.py](./backend/database.py) (Gives you a database connection object, also creates a database.db file if it does not exist)

   * [requirements.txt](./backend/requirements.txt) (Python Dependencies)


   * [recipe\\](./backend/recipe)

      * [recipe\\_\_init__.py](./backend/recipe/__init__.py) (Tell python that this directory is a package)

      * [recipe\routes.py](./backend/recipe/routes.py) (All the API endpoints for recipe related uses eg. get-recipe, search-recipe)

      * [recipe\sql\\](./backend/recipe/sql) (Contains the sql queries for recipe)

