CurveAnimationApp
==============

This project provides a WebApp that allows the user to create 2D Animations through sketches also referred performance-based animations. It was part of a research in the Computer Graphics Lab at UFRJ, Brazil with the goal of exploring how to improve the process of creating 2D animations.

[![Netlify Status](https://api.netlify.com/api/v1/badges/e46523b5-2ec1-426c-9004-bc01a0296a1e/deploy-status)](https://app.netlify.com/sites/curveanimation/deploys)

Due to the fact this project was developed **6 years ago** and I was in a Portuguese speaking University, many comments/variables/commits may be in Portuguese instead of English.
Additionally, many coding practices are considered outdated or were not in the best way possible due to lack of experience.

This is a small image of how the application looked like:
![CurveAnimation Example](https://github.com/guiherzog/curveAnimation/blob/master/web-export/img/demo.png?raw=true)

## Development Instructions 
To run this application in development mode, execute the following steps:

  1. Clone Repository:
    ```
      $ git clone https://github.com/guiherzog/curveAnimation.git
    ```
  2. Rum NPM Install:
    ```
    $ npm install (or yarn install)
    ```
  3. Because this project uses some *outdated* build tools a few extra things are needed:

    Install Grunt
    ```
    $ npm i -g grunt-cli
    ```

    Install any HTTP Server
    ```
    $ npm i -g http-server
    ```

  4. Start Grunt inside the project's root. Grunt will watch for file changes and re-export them.
    ```
    $ grunt
    ```

  5. Run the project using a HTTP server
    ```
    $ http-server ./web-export
    ```

