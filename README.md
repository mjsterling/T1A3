# Gemillionaire - T1A3 Terminal Application - Matthew Sterling

Github link: https://github.com/mjsterling/T1A3

## Software Development Plan

### Overview

My T1A3 terminal app will be a playable version of the Who Wants To Be A Millionaire game show.

### Purpose

The app will allow users to play a terminal-based interpretation of the popular game show Who Wants To Be A Millionaire, in which players are presented with a series of multiple choice questions and are awarded increasing amounts of points (represented by gems) for subsequent correct answers. Answering fifteen questions in a row correctly will enable them to win the maximum prize of one million gems.
The application will consist of a main menu, enabling users to either start a new game, view their hiscores and statistics, read instructions on how to play the game, or exit the application. 

The game window will display a score bar at the top outlining the player's current score and subsequent possible scores for each question, the current displayed question (selected at random from a pool of questions stored in JSON format), and a TTY-Prompt list of possible options, including the four possible multiple choice answers, an option to walk away with one's current earnings, and the three tradition Who Wants To Be A Millionaire lifelines (*50/50*, *Phone A Friend* and *Ask The Audience*)

The app is intended to showcase my skill level as a developer by designing and creating a playable version of a recognisable game. It will potentially assist with my career progression by adding to my overall portfolio of work. Additionally, by releasing it as a gem it will provide a redistributable method for users to practise general knowledge, have fun and learn new things.

The target audience is anyone who wants to play a free trivia game in their terminal; juxtaposing the ubiquity of trivia games as a hobby against the relative dearth of terminal enthusiasts, people who know enough to install a Ruby gem and people who know about the app means the target audience probably intersects solely at my educators and possibly classmates.

A user will download and use the app by ensuring they have Ruby >2.7.2 installed, then either installing the gem in their terminal and running it in IRB, or by downloading a production copy from my Github and executing a shell script which will be packaged with the application.

### Features

- Entry Menu:

    The entry menu will be shown when the app is started, and will contain a welcome message and graphic and then a user-selection menu where users can either **Start** a new game of Who Wants To Be A Millionaire, view their local **Hiscores and Statistics**, or **Exit** the app. The menu will be built in TTY Prompt, removing the possibility of errors when the user inputs their menu selection.

- Game:

    The game will present users with a series of multiple choice questions, selected at random from an attached JSON file, and allow them to either Select an answer, Walk away, or use a Lifeline. The user's score will be displayed at the top of the screen, and each subsequent correct answer will increase their score. Fifteen correct answers in a row will reward the user with one million gems; getting a question wrong will revert the user to their most recent "safe point"; 25,000 gems at ten questions correct, 5,000 gems at five questions correct, or zero if below that.

- Hiscores and Statistics

    This screen will allow users to track their hiscores and average earnings per game, and will be stored in a JSON file. The hiscores page will be accessible from the main menu and will display the user's **Total Games Played**, **Highest Score**, **Total Earnings**, and **Average Earnings per Game**. These statistics will be stored in a JSON file at the conclusion of each game, and the average earnings calculated by dividing total earnings by number of games, with a catch clause to display zero if no games have been completed.

- Lifelines

    The lifelines in the application will do their best to emulate the lifelines in the television version.

    - 50/50 removes two incorrect answers from the TTY Prompt menu, leaving the player with a choice between the correct answer and one random incorrect answer;
    - Ask the audience will show a percentage based graph of each of the four answers, the accuracy of which will be based on RNG: 2/3 of the time the correct answer will be heavily weighted, and the other 1/3 of the time the answers will be entirely random.
    - Phone a friend will give the correct answer a decent amount of the time, again based on RNG - 2/3 of the time the "friend" will tell you the correct answer, whereas the other 1/3 an answer will be selected at random.

### UI/UX

The opening screen will present a selection menu where users can select which part of the application they wish to visit.

There will be a help/instructions screen telling users how to play the game, accessible from the main menu.

All menus will be built in TTY Prompt, meaning users can conveniently navigate through menu options using arrow keys - TTY Prompt automatically tells users how to navigate through the menu at each menu display point.

### Diagram:




