# Recipe Book: Recipe Management System

Recipe Book is a web application for sharing, moderating and discovering recipes. It is built with Flask on top of a PostgreSQL database, and most of its business logic lives inside the database itself as stored procedures, functions, triggers and views. Visitors can browse and search approved recipes, registered users can publish their own recipes with step by step instructions, review and favourite other recipes, and administrators moderate every submission before it goes live.

![Home page](food%20management%20system/output%20images/Screenshot%202025-05-13%20153946.png)

## Features

The application recognises three kinds of user. A **guest** only enters an email address and can then browse the recipe catalogue, filter it by category (Veg, Non-veg, Desserts, Drinks), search by name and open any recipe to read its ingredients, steps, reviews and recommendations. A **registered user** signs in with email and password and can additionally add recipes through a two step form, upload a photo, rate and review recipes, keep a favourites list and manage everything from a personal profile page that also shows rejected recipes with the admin's reason. An **admin** gets a separate dashboard with totals for recipes, pending approvals, users and reviews, and pages to approve or reject pending recipes, delete any recipe, remove users together with all their content, and delete reviews.

On the database side, triggers enforce the business rules (minimum cooking time and servings, valid difficulty level, at least one ingredient per recipe, and no step may use more of an ingredient than the recipe lists), new recipes automatically enter moderation as Pending, ratings are averaged in a view that drives the home page, and a recommendation function suggests the best rated recipes from the same category.

## Tech stack

| Layer | Technology |
| :--- | :--- |
| Backend | Python 3.10+, Flask 3 |
| Database | PostgreSQL 13+ (tested on 16), PL/pgSQL |
| Database driver | psycopg2 |
| Frontend | Jinja2 templates, HTML, CSS, vanilla JavaScript |
| Images | Pillow (placeholder image generation) |

## Project structure

```
Recipe-management-system/
├── README.md
├── requirements.txt
├── .env.example                  template for database settings
├── .gitignore
├── docs/
│   └── Project_Report.md         full project report
└── food management system/
    ├── app.py                    Flask application (all routes)
    ├── db.sql                    original development SQL workbook
    ├── database/
    │   ├── schema.sql            clean schema: tables, views, functions, procedures, triggers, indexes
    │   ├── seed.sql              sample users, recipes, reviews and favourites
    │   └── roles.sql             optional PostgreSQL roles for admin, registered_user, guest
    ├── templates/                Jinja2 pages (user side and admin side)
    ├── static/                   CSS, default images, uploads/
    └── output images/            screenshots
```

`db.sql` is kept as the original working file used while developing the project. It contains test calls and drop statements in between definitions, so use the files in `database/` to set up a new database.

## Setup

You need Python 3.10 or newer and a running PostgreSQL server.

**1. Clone the repository and install the dependencies.**

```bash
git clone https://github.com/Ruthvi5/Recipe-management-system.git
cd Recipe-management-system
python -m venv venv
source venv/bin/activate          # on Windows: venv\Scripts\activate
pip install -r requirements.txt
```

**2. Create the database and load the schema and sample data.**

```bash
cd "food management system"
createdb -U postgres recipe_db
psql -U postgres -d recipe_db -f database/schema.sql
psql -U postgres -d recipe_db -f database/seed.sql
psql -U postgres -d recipe_db -f database/roles.sql      # optional
```

On Windows, if `createdb` is not on your PATH, open pgAdmin or SQL Shell (psql), run `CREATE DATABASE recipe_db;`, then run the two files with `\i database/schema.sql` and `\i database/seed.sql` from inside the `food management system` folder.

**3. Configure the connection.** Copy `.env.example` from the repository root into the `food management system` folder as `.env` and set your PostgreSQL password:

```bash
cp ../.env.example .env
```

```
DB_NAME=recipe_db
DB_USER=postgres
DB_PASSWORD=your_postgres_password
DB_HOST=localhost
DB_PORT=5432
SECRET_KEY=any-long-random-string
```

**4. Run the app.**

```bash
python app.py
```

Then open http://127.0.0.1:5000 in your browser.

## Demo accounts

The sample data creates these accounts. Any email that is not in the database is signed in as a new guest.

| Role | Email | Password |
| :--- | :--- | :--- |
| Admin | admin@example.com | 123456 |
| Registered user | anna@example.com | cookitup |
| Registered user | user@example.com | 654321 |
| Guest | guest@example.com | (none) |

The seed loads 12 users, 20 recipes (17 approved, 2 pending and 1 rejected, so every admin screen has something to show), 37 ingredients, 15 reviews and 13 favourites.

## Database design

The schema has eight tables. `user_table` stores every visitor with a `category` of guest, registered_user or admin. `recipe` holds each submission with its moderation `status` and `rejection_reason`. `ingredient` and `instruction` are shared master lists, so the same ingredient name or instruction text is stored once and reused across recipes. `recipe_ingredient` records the total quantity of each ingredient a recipe needs, and `inst_ing_recipe` links each numbered step of a recipe to its instruction and to the ingredients and amounts used in that step. `review` holds one rating and comment per user per recipe, and `favorites` holds bookmarks.

| Object type | Names |
| :--- | :--- |
| Procedures | `insert_guest_user_if_not_exists`, `register_user`, `add_recipe_with_ingredients`, `into_inst_ing_recipe`, `add_recipe_to_favorites`, `delete_review`, `reject_recipe`, `delete_recipe_by_user`, `delete_recipe_admin`, `delete_user_and_all_recipes` |
| Functions | `get_recipe_ingredient_details`, `get_recipe_instruction_details`, `get_recipe_review_details`, `recommend_recipes_by_category_rating`, `count_favorites_for_recipe`, `update_review` |
| Views | `view_recipes_by_avg_rating`, `view_user_favorites`, `view_user_profile_details` |
| Triggers | cooking time and servings check, default Pending status, created at timestamps for recipes, users and reviews, at least one ingredient, step quantity within recipe total, valid difficulty, positive step quantity |
| Indexes | 15, including unique `(user_id, recipe_id)` on reviews and unique `(user_id, recipe_name)` on recipes |

The full design, the ER model, normalisation and a description of every procedure and trigger are in the [project report](docs/Project_Report.md).

## Screenshots

| | |
| :---: | :---: |
| ![Email login](food%20management%20system/output%20images/Screenshot%202025-05-13%20153653.png) Email step of login | ![Password](food%20management%20system/output%20images/Screenshot%202025-05-13%20153707.png) Password step for registered users and admins |
| ![Search](food%20management%20system/output%20images/Screenshot%202025-05-13%20154005.png) Searching for "chicken" | ![Favourites](food%20management%20system/output%20images/Screenshot%202025-05-13%20154119.png) Favourites panel |
| ![Add recipe](food%20management%20system/output%20images/Screenshot%202025-05-13%20154028.png) Add recipe, step 1 | ![Add instructions](food%20management%20system/output%20images/Screenshot%202025-05-13%20154056.png) Add recipe, step 2 (instructions) |
| ![Recipe details](food%20management%20system/output%20images/Screenshot%202025-05-13%20161124.png) Recipe details with recommendations | ![Ingredients and steps](food%20management%20system/output%20images/Screenshot%202025-05-13%20161405.png) Ingredients and instructions |
| ![Reviews](food%20management%20system/output%20images/Screenshot%202025-05-13%20161451.png) Reviews and the review form | ![Profile](food%20management%20system/output%20images/Screenshot%202025-05-13%20154148.png) Profile with rejected recipes |
| ![Admin dashboard](food%20management%20system/output%20images/Screenshot%202025-05-13%20154220.png) Admin dashboard | |

## Main routes

| Route | Who | Purpose |
| :--- | :--- | :--- |
| `/email-verification`, `/password-verification` | everyone | two step sign in |
| `/register`, `/logout` | everyone | account management |
| `/` | everyone | recipe catalogue with search and category filter |
| `/recipe-details?name=` | everyone | full recipe, reviews, recommendations |
| `/add-recipe`, `/add-recipe-instructions` | registered users | two step recipe submission |
| `/profile`, `/delete_recipe/<id>` | registered users | own recipes, favourites, rejected recipes |
| `/toggle-favorite/<id>`, `/get-favorites`, `/remove-favorite` | registered users | favourites |
| `/submit-review`, `/delete-review` | registered users, admin | reviews |
| `/admin-dashboard`, `/admin-recipes`, `/pending-recipes` | admin | overview and moderation |
| `/approve-recipe/<id>`, `/reject-recipe/<id>`, `/admin/delete_recipe/<id>` | admin | moderation actions |
| `/admin/users`, `/admin/reviews` | admin | user and review management |

## Notes and known limitations

This is an academic project and is not hardened for production use. Passwords are stored and compared in plain text, recipe pages are looked up by recipe name (two users may publish recipes with the same name), and the Flask development server runs with `debug=True`. Before deploying it anywhere public, passwords should be hashed (for example with `werkzeug.security`), recipes should be addressed by `recipe_id`, and debug mode should be turned off. These points are discussed further in the report.
