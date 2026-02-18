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
