<h1 align="center"> Term Project </h1>

<p align="center">
  
</p>

![-------------------------------------------------------------------------](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/cloudy.png)



## :book: Table of Contents

<details open="open">
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#about-the-project">About The Project</a></li>
    <li><a href="#instructions">User Instructions</a></li>
    <li><a href="#technology">Technology</a></li>
    <li><a href="#setting-up-your-environments">Setting Up Your Environment</a></li>
    <li><a href="#future">Future Development</a></li>
    <li><a href="#bugs">Known Bugs</a></li>
    <li><a href="#credits">Credits</a></li>
  </ol>
</details>

![-------------------------------------------------------------------------](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/cloudy.png)


<h2 id="about-the-project"> :pencil: About The Project</h2>

Term Project is an action-packed real-time multiplayer lane battle game where players face off on opposite ends of the battlefield. Spawn troops, manage resources, and unleash powerful abilities as you push through enemy defenses to destroy their base before they destroy yours!

Powered by the Phoenix Framework (Elixir for the backend) and JavaScript for the frontend, Term Project offers blazing-fast gameplay with real-time updates, smooth animations, and engaging strategic combat.


![-------------------------------------------------------------------------](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/cloudy.png)


<h2 id="instructions"> :video_game: User Instructions</h2>

Getting started with Term Project is simple. Here's how:

### Authentication Process

Before starting the game, you must go through an authentication process to ensure only registered users can access the service:
- Log in using one of the following options:
  - GitHub credentials
  - Google credentials           
- Once successfully authenticated, you will be redirected to the main menu

### Starting the Game

1. Press **Start Game** on the main menu and enter your **username**.

2. On the next screen, you can choose how to proceed:
   - **Create a Game**: Set up a new game session.
   - **Matchmaking**: Automatically join an available game lobby.
   - **Join a Lobby**: Select an open lobby manually.
   - **Chat**: Interact with other players while waiting.

3. Once you enter a **lobby**, you can **set your ready state**.

4. When **both players are ready**, a **countdown** begins.  
   The game starts automatically when the countdown hits **0**.



### In-Game Mechanics

- **Creating Units**:
   - Select the unit you want to create.
   - Spend resources (**Wood**, **Stone**, or **Iron**) to deploy the unit.

- **Resource Generation**:
   - Resources (**Wood**, **Stone**, and **Iron**) generate automatically over time.  
   - Monitor and spend them strategically to overwhelm your opponent.



### Winning the Game

- Your goal is to **destroy the opposing player’s base**.
- Strategically spawn units, manage resources, and defend your base while pushing forward to victory!

![-------------------------------------------------------------------------](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/cloudy.png)

<h2 id="technology"> :computer: Technology</h2>
 
### (1) Backend Framework
The backend is built using Phoenix Framework:

- A high-performance web framework written in Elixir.
- Known for scalability, real-time capabilities, and fault tolerance.

### (2) Authentication
Authentication is managed using Ueberauth:

- A flexible authentication library for Phoenix.
- Supports OAuth providers like:
  - GitHub credentials
  - Google credentials
-Ensures that only registered users can access the service.

### (3) Database
The project uses PostgreSQL as the database:

A relational database for storing:
- User accounts 
- authentication data

### (4) In-Memory Storage

ETS (Erlang Term Storage) is used for fast, real-time data management:
- Tracks lobby information
  
### (5) Frontend
The frontend is developed with:

- HTML/CSS: Provides structure and styling.
- JavaScript: Adds interactivity and dynamic behavior.
- Communicates with the backend for real-time updates.

![-------------------------------------------------------------------------](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/cloudy.png)

<h2 id="setting-up-your-environments"> :wrench: Setting Up Your Environment</h2>

### (1) Clone the Repository

First, clone the project repository to your local system:

- Open your terminal  
- Run the following command to clone the repository:  
  `git clone https://github.com/ParadigmsW24/Paradigms-Class-Project](https://github.com/ParadigmsW24/Paradigms-Class-Project.git`
- Move into the project directory:  
  `cd Paradigms-Class-Project`  
- Open the project in VSCode:  
  `code .` 

### (2) Set Up Postgresql Database 

Set up the required PostgreSQL database for the project:
- Open PostgreSQL (CLI or GUI)
- Run the following command to create the database:   
  `CREATE DATABASE your_database_name;`     
  - Replace your_database_name with the name of your choice

### (3) Create .env File

Create the .env file for database configuration:
- In the project root directory, create a file named .env
- Add the following content:     
  `DB_NAME=your_database_username`     
  `DB_PASSWORD=your_database_password`     
  `DB_HOST=your_database_host`     
  `DB_DATABASE=your_database_name`     
  - Replace the placeholders with your actual database configuration:
    - your_database_username: Replace with your PostgreSQL username
    - your_database_password: Replace with your PostgreSQL password
    - your_database_host: Replace with your database host (e.g., localhost)
    - your_database_name: Replace with the name of your database


### (4) Install dependencies

Install all the project dependencies:
- Run the following command to fetch dependencies in the terminal:     
  `mix deps.get`

### (5) Start the server

Start the Phoenix server to run the project:
- Run the following command to fetch dependencies in the terminal:     
  `mix phx.server`
- Wait for the server to start successfully
  
### (6) Access application

Access the running application in your browser:
- Open your browser
- Go to the following URL:     
  `http://localhost:4000`

![-------------------------------------------------------------------------](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/cloudy.png)


<h2 id="future"> 🎆 Future Development </h2>

New stuff coming soon

![-------------------------------------------------------------------------](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/cloudy.png)


<h2 id="bugs"> 🐛 Known Bugs</h2>

Too many to list

![-------------------------------------------------------------------------](https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/cloudy.png)


<h2 id="credits"> :pray: Credits</h2>

Thanks to everyone in term 4 CST and Albert!
