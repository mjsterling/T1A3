# Gemillionaire - T1A3 Terminal Application - Matthew Sterling

Github link: https://github.com/mjsterling/T1A3

## Software Development Plan

### Overview

My T1A3 terminal app will be a playable version of the Who Wants To Be A Millionaire game show.

### Purpose

The app will allow users to play a game in which they are presented with a series of multiple choice questions and are awarded increasing amounts of points (represented by gems) for subsequent correct answers. Answering fifteen questions in a row correctly will enable them to win the maximum prize of one million gems.

The app is intended to showcase my skill level as a developer by designing and creating a playable version of a recognisable game. Additionally, by releasing it as a gem it will provide a redistributable, terminal-based method for users to practise general knowledge and learn new things.

The target audience is anyone who wants to play a free trivia game in their terminal; the ubiquity of trivia games as a hobby makes it difficult to narrow the audience down to a specific demographic.

A user will download and use the app by either installing the gem in their terminal and then running it in IRB, or by running a shell script which will be packaged with the application.

### Features

- Entry Menu:

    The entry menu will be shown when the app is started, and will contain a welcome message and graphic and then a user-selection menu where users can either **Start** a new game of Who Wants To Be A Millionaire, view their local **Highscores and Statistics**, or **Exit** the app.

- Game:

    The game will present users with a series of multiple choice questions, pulled from an attached JSON file, and allow them to either Select an answer, Walk away, or use a Lifeline.

- Hiscores and Statistics

    This screen will allow users to track their hiscores and average earnings per game, and will be stored in a JSON file.

- Lifelines

    The lifelines in the application will do their best to emulate the lifelines in the television version.

    - 50/50 removes two incorrect answers, leaving the player with only two options;
    - Ask the audience will show a graph, the accuracy of which will be based on RNG;
    - Phone a friend will give the correct answer a decent amount of the time, again based on RNG.