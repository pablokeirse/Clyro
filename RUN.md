# Running the app

quick guide on how to run the app

## Setting up your environment

In the teminal copy paste these commands:

Make a venv (do this only once, you should have a folder called .venv now)
```
python -m venv .venv
```

This should normally be done automatically, if not: Activate venv (normally .venv should be in green next to your name) 
Everytime you'll run the code you should be in your venv
```
.venv/Scripts/activate
```

Install dependencies (should also be done only once)
```
pip install -r requirements.txt
```
flutter dependencies
```
cd app
flutter pub get
```

Once thats done the next 2 sections you'll have to do everytime you run the app

# Backend API + Database (run this first)

## step 1

open new terminal with `CTRL + SHIFT + ù`

## step 2

change to the right folder
```
cd backend
```

activate backend
```
uvicorn main:app --reload --port 8000
```

Backend should start up cleanly.

You can see the backend for debugging on this address:
```
http://localhost:8000
```
to stop just hit `CTRL + C`

Now you are ready to run the actuall app

# App

## step 1

open a new terminal with `CTRL + SHIFT + ù`

## step 2

In the teminal copy paste these commands:

Activate venv if not done automatically
```
.venv/scripts/activate
```

Change to the right folder
```
cd app
```

Activate the app
```
flutter run -d chrome
```

App should start up automatically. Can take some time tho.

To close the app press q in this terminal
```
q 
```