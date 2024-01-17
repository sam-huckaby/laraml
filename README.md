![Screenshot from 2024-01-16 21-35-11](https://github.com/sam-huckaby/laraml/assets/5497597/a083fba7-a9c8-4ebe-8df5-5ac83984a52f)

# Laraml
I DON'T KNOW IF THIS NAME WILL STICK BUT IT'S THE ONLY NAME THAT SOUNDED OKAY THAT I COULD GET A DOMAIN FOR

It's time to start making OCaml an easy-to-reach-for choice to build web apps.

## Development Setup

### Step 1: Database
Currently the only tested database is PostgreSQL, but in theory SQLite should work as well.

Laraml leverages a .env file to populate secrets (because we aren't barbarians).
If you want to configure a database, you will need to set the following values in your .env
- `DB_DRIVER` -> The kind of database you are using (e.g. postgresql)
- `DB_HOST` -> The host of the database instance
- `DB_PORT` -> The port that the database is using
- `DB_NAME` -> The name of the database
- `DB_PASS` -> the password of the database user
- `DB_USER` -> The username of the database user



### Step 2: Tailwind
This project uses tailwind, but does not install it via npm. You may choose to do so, but the preferred solution
is to download the [Tailwind CLI](https://tailwindcss.com/blog/standalone-cli) and run it that way.

With the Tailwind CLI, you will use `www/static/global.css` as the input and `www/static/build.css` as the output like so:

```
./tailwindcss -i www/static/global.css -o www/static/build.css --watch
```

The `--watch` flag will keep the process running and update the CSS in the background as you swap tailwind classes in and out.

### Step 3: Development
You can start Laraml via dune:
```
dune exec laraml
```

This will start the app on port 8080.

There will be JavaScript libraries added in the future, because I want the default auth solution to be passkeys. BECAUSE PASSWORDS ARE THE WORST.
Beyond Identity provides a passkey SDK that is easy too use and free under a certain amount of auths which I will bake in soon, and I'll be investigating other built-in options we can add.

