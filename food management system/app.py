from flask import Flask, render_template, request, redirect, url_for, session, flash, jsonify
from datetime import datetime
import psycopg2
import os
from werkzeug.utils import secure_filename
import base64
from PIL import Image, ImageDraw
from io import BytesIO

app = Flask(__name__)
app.secret_key = b'_5#y2L"F4Q8z\n\xec]/'

# Database configuration
dbname = 'postgres'
username = 'postgres'
password = '59@Mahaa'
host = 'localhost'


UPLOAD_FOLDER = 'static/uploads'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER


def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


def create_default_recipe_image():
    default_image_path = os.path.join('static', 'images', 'default-recipe.jpg')
    if not os.path.exists(default_image_path):
        img = Image.new('RGB', (400, 300), color=(240, 240, 240))
        d = ImageDraw.Draw(img)
        
        text = "Recipe Image"
        text_color = (100, 100, 100)
        text_position = (150, 140)
        d.text(text_position, text, fill=text_color)
        img.save(default_image_path)
        
    return default_image_path

create_default_recipe_image()


# Create a connection to PostgreSQL
def connect_db():
    return psycopg2.connect(dbname=dbname, user=username, password=password, host=host)

def execute_sql_query(query, params=None, fetch=True):
    connection = connect_db()
    cursor = connection.cursor()
    try:
        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)
        
        if fetch:
            data = cursor.fetchall()
        else:
            data = None
        
        connection.commit()
        return data
    except Exception as e:
        connection.rollback()
        raise e
    finally:
        cursor.close()
        connection.close()

@app.route('/')
def index():

    if not session.get('logged_in') and not session.get('user_type') == 'guest':
        return redirect(url_for('email_verification'))
    
    category = request.args.get('category')
    search_query = request.args.get('search')
    conn = connect_db()
    cur = conn.cursor()
    
    if search_query:
        cur.execute("SELECT * FROM view_recipes_by_avg_rating WHERE recipe_name ILIKE %s", (f'%{search_query}%',))
    elif category:
        cur.execute("SELECT * FROM view_recipes_by_avg_rating WHERE category = %s", (category,))
    else:
        cur.execute('SELECT * FROM view_recipes_by_avg_rating')
    recipes = cur.fetchall()
    conn.close()

    user_type = session.get('user_type', 'guest')
    is_logged_in = user_type in ['admin', 'registered_user']
    default_recipe_image = url_for('static', filename='images/default-recipe.jpg')
    
    return render_template('index.html', 
                        recipes=recipes, 
                        logged_in=is_logged_in,
                        user_type=user_type,
                        current_category=category, 
                        search_query=search_query,
                        default_recipe_image=default_recipe_image)


@app.route('/email-verification', methods=['GET', 'POST'])
def email_verification():
    if request.method == 'POST':
        email = request.form.get('email')
        conn = connect_db()
        cur = conn.cursor()
        
        cur.execute("CALL insert_guest_user_if_not_exists(%s, NULL)", (email,))
        conn.commit()
        cur.execute("SELECT * FROM user_table WHERE email = %s", (email,))
        user = cur.fetchone()
        conn.close()
        
        if user:
            user_category = user[5]
            session['email'] = email
            session['user_type'] = user_category
            
            if user_category == 'guest':
                session['logged_in'] = False
                session['user_type'] = 'guest'
                return redirect(url_for('index'))
            elif user_category in ['admin','registered_user']:
                session['email_verified'] = True
                return redirect(url_for('password_verification'))
            else:
                flash('Invalid user category. Please try again.')
                return redirect(url_for('email_verification'))
            
    return render_template('email_verification.html')


@app.route('/password-verification', methods=['GET', 'POST'])
def password_verification():
    if not session.get('email_verified'):
        return redirect(url_for('email_verification'))
    
    if request.method == 'POST':
        password = request.form.get('password')
        conn = connect_db()
        cur = conn.cursor()
        cur.execute("SELECT * FROM user_table WHERE email = %s AND passcode = %s", 
                    (session['email'], password))
        user = cur.fetchone()
        conn.close()
        
        if user:
            session['password_verified'] = True
            session['logged_in'] = True
            session['user_id'] = user[0]
            session['user_type'] = user[5]
            
            if session['user_type'] == 'admin':
                return redirect(url_for('admin_dashboard'))
            elif session['user_type'] == 'registered_user':
                return redirect(url_for('index'))
            else:
                flash('Invalid user category. Please try again.')
                return redirect(url_for('password_verification'))
        else:
            flash('Incorrect password. Please try again.')
            return redirect(url_for('password_verification'))
    
    return render_template('password_verification.html')


@app.route('/admin-dashboard')
def admin_dashboard():
    if not session.get('logged_in') or session.get('user_type') != 'admin':
        return redirect(url_for('index'))
    
    try:
        conn = connect_db()
        cur = conn.cursor()
        
        cur.execute("SELECT user_name FROM user_table WHERE user_id = %s", (session['user_id'],))
        admin_user = cur.fetchone()
        admin_name = admin_user[0] if admin_user else 'Admin'
        cur.execute("SELECT COUNT(*) FROM recipe")
        total_recipes = cur.fetchone()[0]
        
        cur.execute("SELECT COUNT(*) FROM recipe WHERE status = 'Pending'")
        pending_recipes = cur.fetchone()[0]
        
        cur.execute("SELECT COUNT(*) FROM user_table")
        total_users = cur.fetchone()[0]
        
        cur.execute("SELECT COUNT(*) FROM review")
        total_reviews = cur.fetchone()[0]
        conn.close()
        
        return render_template('admin_index.html',
                            total_recipes=total_recipes,
                            pending_recipes=pending_recipes,
                            total_users=total_users,
                            total_reviews=total_reviews,
                            admin_name=admin_name)
    except Exception as e:
        print(f"Error: {str(e)}")
        return redirect(url_for('index'))

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('email_verification'))

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form.get('username')
        email = request.form.get('email')
        password = request.form.get('password')
        phone = request.form.get('phone')
        
        try:
            conn = connect_db()
            cur = conn.cursor()
            
            cur.execute("""
                CALL register_user(%s, %s, %s, %s)
            """, (username, email, password, phone))
            
            conn.commit()
            conn.close()
            
            session['logged_in'] = True
            session['email'] = email
            session['user_type'] = 'registered_user'
            
            conn = connect_db()
            cur = conn.cursor()
            cur.execute("SELECT user_id FROM user_table WHERE email = %s", (email,))
            user = cur.fetchone()
            conn.close()
            
            if user:
                session['user_id'] = user[0]
            
            return redirect(url_for('index'))
            
        except Exception as e:
            return render_template('register.html', error=str(e))
        
    return render_template('register.html')


@app.route('/add-recipe', methods=['GET', 'POST'])
def add_recipe():
    if request.method == 'POST':
        try:
            recipe_name = request.form.get('recipe-name')
            description = request.form.get('description')
            cooking_time = request.form.get('cooking-time')
            servings = request.form.get('servings')
            category = request.form.get('category')
            difficulty = request.form.get('difficulty')
            ingredients = request.form.getlist('ingredient')
            quantities = request.form.getlist('amount')
            units = request.form.getlist('unit')
            
            ingredients = [i for i in ingredients if i]
            quantities = [q for q in quantities if q]
            units = [u for u in units if u]
            
            quantities = [float(q) for q in quantities]
            user_id = session.get('user_id')
            if not user_id:
                flash('Please log in to add a recipe')
                return redirect(url_for('email_verification'))
            image_url = 'https://example.com/default_recipe.jpg'  # Default image URL
            if 'recipe-image' in request.files:
                file = request.files['recipe-image']
                if file and file.filename != '' and allowed_file(file.filename):
                    filename = secure_filename(file.filename)
                    timestamp = datetime.now().strftime('%Y%m%d%H%M%S')
                    filename = f"{timestamp}_{filename}"
                    file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
                    image_url = f"/static/uploads/{filename}"

            conn = connect_db()
            cur = conn.cursor()
            
            try:
                cur.execute("""
                    CALL add_recipe_with_ingredients(
                        %s,  -- user_id
                        %s,  -- recipe_name
                        %s,  -- description
                        %s,  -- cooking_time
                        %s,  -- servings
                        %s,  -- image_url
                        %s,  -- category
                        %s,  -- difficulty_level
                        %s,  -- ingredient_names
                        %s,  -- quantities
                        %s   -- units
                    )
                """, (
                    user_id,
                    recipe_name,
                    description,
                    cooking_time,
                    servings,
                    image_url,
                    category,
                    difficulty,
                    ingredients,
                    quantities,
                    units
                ))

                cur.execute("SELECT recipe_id FROM recipe WHERE recipe_name = %s", (recipe_name,))
                recipe_id_result = cur.fetchone()
                
                if recipe_id_result:
                    session['current_recipe_id'] = recipe_id_result[0]
                
                conn.commit()
                conn.close()
                return redirect(url_for('add_recipe_instructions'))
                
            except Exception as e:
                conn.rollback()
                conn.close()
                error_message = str(e)
                
                if 'Invalid difficulty level' in error_message:
                    flash('Invalid difficulty level. Must be "Easy", "Medium", or "Hard".')
                elif 'ingredients must be at least 1' in error_message:
                    flash('Error: A recipe must have at least one ingredient. Please add at least one ingredient to your recipe.')
                elif 'Cooking time must be at least 2 minutes' in error_message:
                    flash('Cooking time must be at least 2 minutes')
                elif 'Servings must be at least 1' in error_message:
                    flash('Servings must be at least 1')
                else:
                    flash('Error adding recipe. Please check your input and try again.')
                
                return render_template('add_recipe-1.html',
                    recipe_name=recipe_name,
                    description=description,
                    cooking_time=cooking_time,
                    servings=servings,
                    category=category,
                    difficulty=difficulty,
                    ingredients=ingredients,
                    quantities=quantities,
                    units=units
                )
        except Exception as e:
            flash('An unexpected error occurred. Please try again.')
            return redirect(url_for('add_recipe'))
            
    return render_template('add_recipe-1.html')

@app.route('/add-recipe-instructions', methods=['GET', 'POST'])
def add_recipe_instructions():
    if request.method == 'POST':
            recipe_id = session.get('current_recipe_id')
            if not recipe_id:
                flash('No recipe found. Please start over.')
                return redirect(url_for('add_recipe'))

            instructions = request.form.getlist('instruction')
            ingredients = request.form.getlist('ingredient')
            quantities = request.form.getlist('amount')
            units = request.form.getlist('unit')
            instruction_counts = request.form.getlist('instruction_count')
            step_numbers = list(range(1, len(instructions) + 1))
            print(step_numbers)
            quantities = []
            for q in request.form.getlist('amount'):
                if q.strip(): 
                    try:
                        quantities.append(float(q))
                    except ValueError:
                        quantities.append(None)
                else:
                    quantities.append(None)
                    
            final_instructions = []
            final_ingredients = []
            final_quantities = []
            final_units = []

            current_ingredient_index = 0
            for i in range(len(instructions)):
                final_instructions.append(instructions[i])
                try:
                    step_ingredient_count = int(instruction_counts[i])
                except (ValueError, IndexError):
                    step_ingredient_count = 1
                step_ingredients = []
                step_quantities = []
                step_units = []
                
                for j in range(step_ingredient_count):
                    if current_ingredient_index < len(ingredients):
                        step_ingredients.append(ingredients[current_ingredient_index])
                        step_quantities.append(quantities[current_ingredient_index])
                        step_units.append(units[current_ingredient_index])
                        current_ingredient_index += 1
                
                final_ingredients.append(step_ingredients)
                final_quantities.append(step_quantities)
                final_units.append(step_units)
            
            max_ingredients = max(len(lst) for lst in final_ingredients)
            max_quantities = max(len(lst) for lst in final_quantities)
            max_units = max(len(lst) for lst in final_units)
            
            for i in final_ingredients:
                while len(i) < max_ingredients:
                    i.append(None)
            for i in final_quantities:
                while len(i) < max_quantities:
                    i.append(None)
            for i in final_units:
                while len(i) < max_units:
                    i.append(None)
                    
            conn = connect_db()
            cur = conn.cursor()
            
            try:
                cur.execute("""
                    call into_inst_ing_recipe(
                        %s::INTEGER,
                        %s::TEXT[],
                        %s::TEXT[][],
                        %s::DECIMAL(10,2)[][],
                        %s::VARCHAR(50)[][]
                    )
                """, (
                    recipe_id,
                    final_instructions,
                    final_ingredients,
                    final_quantities,
                    final_units
                ))
                
                conn.commit()
                conn.close()
                
                session.pop('current_recipe_id', None)
                
                flash('Recipe added successfully!')
                return redirect(url_for('index'))
                
            except Exception as e:
                conn.rollback()
                conn.close()
                error_message = str(e)
                
                if 'record "new" has no field "quantity"' in error_message:
                    flash('Database error: The trigger is looking for a field named "quantity" but your table has a field named "used_quantity". Please update your trigger to use the correct field name.')
                elif 'Ingredient quantity must be greater than 0' in error_message:
                    flash('Error: Ingredient quantity must be greater than 0. Please check your ingredient amounts.')
                else:
                    flash(f'Error adding instructions: {str(e)}')
                
                return redirect(url_for('add_recipe_instructions'))
            
    recipe_id = session.get('current_recipe_id')
    if not recipe_id:
        flash('No recipe found. Please start over.')
        return redirect(url_for('add_recipe'))
    
    conn = connect_db()
    cur = conn.cursor()
    
    cur.execute("SELECT instruction_id, description FROM Instruction")
    db_instructions = []
    for row in cur.fetchall():
        if row and len(row) >= 2:
            db_instructions.append({
                'id': row[0],
                'description': row[1]
            })
    
    cur.execute("""
        SELECT DISTINCT i.name
        FROM ingredient i
        JOIN recipe_ingredient ri ON i.ingredient_id = ri.ingredient_id
        WHERE ri.recipe_id = %s
    """, (recipe_id,))
    
    recipe_ingredients = []
    for row in cur.fetchall():
        if row and row[0]:
            recipe_ingredients.append(row[0])
    conn.close()

    if not db_instructions:
        db_instructions = [
            {'id': 1, 'description': 'Preheat oven to 180°C.'},
            {'id': 2, 'description': 'Mix flour, sugar, and cocoa powder.'},
            {'id': 3, 'description': 'Bake for 45 minutes.'},
            {'id': 4, 'description': 'Season the chicken with spices.'},
            {'id': 5, 'description': 'Grill for 30 minutes.'}
        ]
    return render_template('add_recipe-2.html', 
                            db_instructions=db_instructions,
                            recipe_ingredients=recipe_ingredients)

@app.route('/recipe-details')
def recipe_details():
    recipe_name = request.args.get('name')
    if not recipe_name:
        return redirect(url_for('index'))
    
    conn = connect_db()
    cur = conn.cursor()
    
    cur.execute("SELECT recipe_id FROM recipe WHERE recipe_name = %s", (recipe_name,))
    recipe_id_result = cur.fetchone()
    if not recipe_id_result:
        conn.close()
        return redirect(url_for('index'))
    
    recipe_id = recipe_id_result[0]
    
    has_reviewed = False
    if session.get('logged_in') and session.get('user_id'):
        cur.execute("""
            SELECT 1 FROM review 
            WHERE user_id = %s AND recipe_id = %s
        """, (session['user_id'], recipe_id))
        has_reviewed = cur.fetchone() is not None
    
    cur.execute("SELECT * FROM get_recipe_ingredient_details(%s)", (recipe_id,))
    recipe_data = cur.fetchall()
    
    cur.execute("SELECT * FROM get_recipe_instruction_details(%s)", (recipe_id,))
    instructions_data = cur.fetchall()
    
    cur.execute("SELECT * FROM get_recipe_review_details(%s)", (recipe_id,))
    review_data = cur.fetchall()
    
    cur.execute("SELECT * FROM recommend_recipes_by_category_rating(%s, %s)", (recipe_id, 5))
    recommended_recipes = cur.fetchall()
    
    is_favorite = False
    if session.get('logged_in') and session.get('user_id'):
        cur.execute("""
            SELECT 1 FROM favorites 
            WHERE user_id = %s AND recipe_id = %s
        """, (session['user_id'], recipe_id))
        is_favorite = cur.fetchone() is not None
    
    conn.close()
    
    if not recipe_data:
        return redirect(url_for('index'))
    default_recipe_image = url_for('static', filename='images/default-recipe.jpg')

    recipe_info = {
        'recipe_id': recipe_id,
        'name': recipe_data[0][0],
        'image': recipe_data[0][1] if recipe_data[0][1] else default_recipe_image,
        'description': recipe_data[0][2],
        'cooking_time': recipe_data[0][3],
        'servings': recipe_data[0][4],
        'category': recipe_data[0][5],
        'difficulty_level': recipe_data[0][6],
        'user_name': recipe_data[0][7],
        'ingredients': []
    }
    
    for row in recipe_data:
        if row[8]:  # ingredient_name
            recipe_info['ingredients'].append({
                'name': row[8],
                'quantity': row[9],
                'unit': row[10]
            })

    instructions = []
    current_step = None
    current_instruction = None
    
    for row in instructions_data:
        step_no = row[4]
        instruction = row[1]
        ingredient = row[2]
        quantity = row[3]
        unit = row[5]
        
        if current_step != step_no:
            if current_instruction:
                instructions.append(current_instruction)
            current_step = step_no
            current_instruction = {
                'step_no': step_no,
                'description': instruction,
                'ingredients': []
            }
        
        if ingredient:
            current_instruction['ingredients'].append({
                'name': ingredient,
                'quantity': quantity,
                'unit': unit
            })
    
    if current_instruction:
        instructions.append(current_instruction)
        
    reviews = [{
        'recipe_id': review[0],
        'user_name': review[1],
        'comment': review[2],
        'rating': review[3],
        'user_id': review[4],
        'uploaded_at': review[5]
    } for review in review_data]
    
    recommended_recipes_list = [{
        'name': recipe[0],
        'category': recipe[1],
        'image': recipe[2] if recipe[2] else default_recipe_image,
        'cooking_time': recipe[3],
        'avg_rating': recipe[4]
    } for recipe in recommended_recipes]
    
    return render_template('recipe_details.html', 
                        recipe=recipe_info, 
                        instructions=instructions,
                        reviews=reviews,
                        recommended_recipes=recommended_recipes_list,
                        logged_in=session.get('logged_in'),
                        user_type=session.get('user_type'),
                        is_favorite=is_favorite,
                        has_reviewed=has_reviewed,
                        user_id=session.get('user_id'),
                        default_recipe_image=default_recipe_image)

@app.route('/profile')
def profile():
    if not session.get('logged_in'):
        print("Not logged in")
        return redirect(url_for('email_verification'))

    requested_user_id = request.args.get('id')
    print("Raw requested_user_id from query param:", requested_user_id)
    if not requested_user_id:
        requested_user_id = session.get('user_id')
        print("Using session user_id instead:", requested_user_id)
    else:
        try:
            requested_user_id = int(requested_user_id)
            print("Converted requested_user_id to int:", requested_user_id)
        except ValueError:
            print("Failed to convert requested_user_id to int")
            return redirect(url_for('index'))

    if not requested_user_id:
        return redirect(url_for('index'))

    try:
        conn = connect_db()
        cur = conn.cursor()
        cur.execute("SELECT * FROM view_user_profile_details WHERE user_id = %s", (requested_user_id,))
        profile_data = cur.fetchall()
        conn.close()

        if not profile_data:
            print("No profile data found")
            return redirect(url_for('index'))

        user_info = {
            'user_id': profile_data[0][0],
            'user_name': profile_data[0][1],
            'image': profile_data[0][2],
            'joined_on': profile_data[0][3],
            'total_recipes_created': profile_data[0][4],
            'total_favorites': profile_data[0][5]
        }

        created_recipes = []
        rejected_recipes = []
        favorited_recipes = []

        for row in profile_data:
            recipe = {
                'recipe_id': row[6],
                'name': row[7],
                'image': row[8],
                'category': row[9],
                'cooking_time': row[10],
                'favorite_count': row[11],
                'status': row[13],
                'rejection_reason': row[14]
            }

            if row[12] == 'created':
                created_recipes.append(recipe)
            elif row[12] == 'favorite':
                favorited_recipes.append(recipe)
            elif row[12] == 'rejected':
                rejected_recipes.append(recipe)

        return render_template('profile.html',
                                user=user_info,
                                created_recipes=created_recipes,
                                rejected_recipes=rejected_recipes,
                                favorited_recipes=favorited_recipes,
                                logged_in=session.get('logged_in'),
                                default_recipe_image=url_for('static', filename='images/default-recipe.jpg'))
    except Exception as e:
        print(f"Error in profile route: {str(e)}")
        return redirect(url_for('index'))


@app.route('/delete_recipe/<int:recipe_id>', methods=['POST'])
def delete_recipe(recipe_id):
    if not session.get('logged_in'):
        return redirect(url_for('email_verification'))

    try:
        conn = connect_db()
        cur = conn.cursor()

        cur.execute("""
            CALL delete_recipe_by_user(%s, %s)
        """, (session['user_id'], recipe_id))
        conn.commit()
        flash("Recipe deleted successfully.")
        
    except Exception as e:
        flash(f"Error deleting recipe: {str(e)}")
    finally:
        conn.close()
    return redirect(url_for('profile'))


@app.route('/toggle-favorite/<int:recipe_id>', methods=['POST'])
def toggle_favorite(recipe_id):
    if not session.get('logged_in') or not session.get('user_id'):
        return jsonify({'success': False, 'message': 'Please log in first'})
    
    try:
        conn = connect_db()
        cur = conn.cursor()
        cur.execute("CALL add_recipe_to_favorites(%s, %s)", 
                    (session['user_id'], recipe_id))
        
        cur.execute("""
            SELECT 1 FROM favorites 
            WHERE user_id = %s AND recipe_id = %s
        """, (session['user_id'], recipe_id))
        is_favorite = cur.fetchone() is not None
        
        conn.commit()
        conn.close()
        return jsonify({
            'success': True, 
            'is_favorite': is_favorite,
            'message': 'Recipe {} favorites'.format('added to' if is_favorite else 'removed from')
        })
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)})


@app.route('/get-favorites')
def get_favorites():
    
    if not session.get('logged_in') or not session.get('user_id'):
        return jsonify({'success': False, 'message': 'Please log in first'})
    
    default_recipe_image = url_for('static', filename='images/default-recipe.jpg')
    try:
        conn = connect_db()
        cur = conn.cursor()

        cur.execute("""
            SELECT r.recipe_id, r.recipe_name, r.image, r.category, r.cooking_time, f.added_on
            FROM favorites f
            JOIN recipe r ON f.recipe_id = r.recipe_id
            WHERE f.user_id = %s
            ORDER BY f.added_on DESC
        """, (session['user_id'],))
        
        favorites = []
        for row in cur.fetchall():
            favorites.append({
                'recipe_id': row[0],
                'name': row[1],
                'image': row[2] if row[2] else default_recipe_image,
                'category': row[3],
                'cooking_time': row[4],
                'added_on': row[5].strftime('%Y-%m-%d %H:%M:%S') if row[5] else ''
            })
        
        conn.close()
        return jsonify({'success': True, 'favorites': favorites})
        
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)})


@app.route('/remove-favorite', methods=['POST'])
def remove_favorite():
    if not session.get('logged_in') or not session.get('user_id'):
        return jsonify({'success': False, 'message': 'Please log in first'})
    
    try:
        recipe_name = request.args.get('name')
        if not recipe_name:
            return jsonify({'success': False, 'message': 'Recipe name is required'})
        
        conn = connect_db()
        cur = conn.cursor()

        cur.execute("SELECT recipe_id FROM recipe WHERE recipe_name = %s", (recipe_name,))
        recipe = cur.fetchone()
        
        if not recipe:
            conn.close()
            return jsonify({'success': False, 'message': 'Recipe not found'})
        
        recipe_id = recipe[0]
        
        cur.execute("""
            DELETE FROM favorites 
            WHERE user_id = %s AND recipe_id = %s
        """, (session['user_id'], recipe_id))
        
        conn.commit()
        conn.close()
        
        return jsonify({'success': True, 'message': 'Recipe removed from favorites'})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)})
    
    
@app.route('/submit-review', methods=['POST'])
def submit_review():
    if not session.get('logged_in'):
        return jsonify({'success': False, 'message': 'Please log in to submit reviews'})
    try:
        data = request.get_json()
        recipe_id = data.get('recipe_id')
        comment = data.get('comment')
        rating = data.get('rating')

        if not all([recipe_id, comment, rating]):
            return jsonify({'success': False, 'message': 'Missing required fields'})
        
        conn = connect_db()
        cur = conn.cursor()
        cur.execute("SELECT update_review(%s, %s, %s, %s)", (session['user_id'], recipe_id, rating, comment))
        
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({'success': True, 'message': 'Review submitted successfully'})

    except Exception as e:
        return jsonify({'success': False, 'message': str(e)})


@app.route('/admin-recipes')
def admin_recipes():
    if not session.get('logged_in') or session.get('user_type') != 'admin':
        return redirect(url_for('index'))

    conn = connect_db()
    cur = conn.cursor()

    cur.execute("SELECT user_name FROM user_table WHERE user_id = %s", (session['user_id'],))
    admin_user = cur.fetchone()
    admin_name = admin_user[0] if admin_user else 'Admin'

    cur.execute("""
        SELECT r.recipe_id,r.recipe_name, u.user_name, r.category, r.created_at, r.status
        FROM recipe r
        JOIN user_table u ON r.user_id = u.user_id
        ORDER BY r.created_at DESC
    """)
    recipes_data = cur.fetchall()
    conn.close()
    
    recipes = []
    for row in recipes_data:
        recipes.append({
            'id':row[0],
            'name': row[1],
            'submitted_by': row[2],
            'category': row[3],
            'date_added': row[4].strftime('%b %d, %Y') if row[4] else 'N/A',
            'status': row[5].capitalize() if row[5] else 'Pending'
        })
    return render_template('admin_recipe.html', recipes=recipes, admin_name=admin_name)

@app.route('/admin/delete_recipe/<int:recipe_id>', methods=['POST'])
def admin_delete_recipe(recipe_id):

    if not session.get('logged_in') or session.get('user_type') != 'admin':
        flash("You are not authorized to perform this action.")
        return redirect(url_for('index'))

    try:
        conn = connect_db()
        cur = conn.cursor()
        cur.execute("CALL delete_recipe_admin(%s)", (recipe_id,))
        conn.commit()
        flash("Recipe deleted successfully by admin.")

    except Exception as e:
        flash(f"Error deleting recipe as admin: {str(e)}")

    finally:
        conn.close()

    return redirect(url_for('admin_recipes')) 

@app.route('/pending-recipes')
def pending_recipes():
    if not session.get('logged_in') or session.get('user_type') != 'admin':
        return redirect(url_for('index'))
    
    conn = connect_db()
    cur = conn.cursor()
        
    cur.execute("SELECT user_name FROM user_table WHERE user_id = %s", (session['user_id'],))
    admin_user = cur.fetchone()
    admin_name = admin_user[0] if admin_user else 'Admin'
    cur.execute("""
            SELECT r.recipe_id,r.recipe_name, u.user_name, r.category, r.created_at, r.status
            FROM recipe r
            JOIN user_table u ON r.user_id = u.user_id
            WHERE r.status = 'Pending'
            ORDER BY r.created_at DESC
        """)
        
    recipes_data = cur.fetchall()
    conn.close()
        
    recipes = []
    for row in recipes_data:
            recipes.append({
                'id': row[0],
                'name': row[1],
                'submitted_by': row[2],
                'category': row[3],
                'date_added': row[4].strftime('%b %d, %Y') if row[3] else 'N/A',
                'status': row[5].capitalize() if row[5] else 'Pending'
            })
        
    return render_template('recipe_pending.html', recipes=recipes, admin_name=admin_name)


@app.route('/approve-recipe/<recipe_id>', methods=['POST'])
def approve_recipe(recipe_id):
    if not session.get('logged_in') or session.get('user_type') != 'admin':
        return jsonify({'success': False, 'message': 'Unauthorized'})
    
    try:
        conn = connect_db()
        cur = conn.cursor()
        cur.execute("""
            UPDATE recipe 
            SET status = 'Approved' 
            WHERE recipe_id = %s
        """, (recipe_id,))
        
        if cur.rowcount == 0:
            conn.close()
            return jsonify({'success': False, 'message': 'Recipe not found'})
        
        conn.commit()
        conn.close()
        
        return jsonify({'success': True, 'message': 'Recipe approved successfully'})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)})


@app.route('/reject-recipe/<recipe_id>', methods=['POST'])
def reject_recipe(recipe_id):
    if not session.get('logged_in') or session.get('user_type') != 'admin':
        return jsonify({'success': False, 'message': 'Unauthorized'})
    reason = request.json.get('reason',None)
    try:
        conn = connect_db()
        cur = conn.cursor()

        cur.execute("""
            call reject_recipe(%s,%s)
        """, (recipe_id,reason))
        conn.commit()
        conn.close()
        return jsonify({'success': True, 'message': 'Recipe rejected successfully'})
    
    except Exception as e:
        print("Reject Error:", e)
        return jsonify({'success': False, 'message': str(e)})


@app.route('/admin/users')
def admin_users():
    if not session.get('logged_in') or session.get('user_type') != 'admin':
        return redirect(url_for('email_verification'))
    
    conn = connect_db()
    cur = conn.cursor()
    cur.execute("SELECT user_name FROM user_table WHERE user_id = %s", (session['user_id'],))
    admin_user = cur.fetchone()
    admin_name = admin_user[0] if admin_user else 'Admin'
    
    cur.execute("""
        SELECT u.user_id, u.user_name, u.email, u.category, u.created_at,
        COUNT(DISTINCT r.recipe_id) as recipe_count
        FROM user_table u
        LEFT JOIN recipe r ON u.user_id = r.user_id
        GROUP BY u.user_id, u.user_name, u.Email, u.category, u.created_at
        ORDER BY u.created_at DESC
    """)
    
    users = []
    for row in cur.fetchall():
        users.append({
            'id': row[0],
            'username': row[1],
            'email': row[2],
            'role': row[3],
            'joined_date': row[4].strftime('%Y-%m-%d') if row[4] else 'N/A',
            'recipe_count': row[5]
        })
    cur.close()
    conn.close()
    
    return render_template('admin_user.html', users=users, admin_name=admin_name)

@app.route('/admin/users/<int:user_id>', methods=['DELETE'])
def delete_user(user_id):
    if not session.get('logged_in') or session.get('user_type') != 'admin':
        return jsonify({'success': False, 'message': 'Unauthorized'}), 403

    try:
        conn = connect_db()
        cur = conn.cursor()
        cur.execute("SELECT category FROM user_table WHERE user_id = %s", (user_id,))
        result = cur.fetchone()

        if not result:
            return jsonify({'success': False, 'message': 'User not found'}), 404
        if result[0].lower() == 'admin':
            return jsonify({'success': False, 'message': 'You cannot delete another admin.'}), 403

        cur.execute("CALL delete_user_and_all_recipes(%s);", (user_id,))
        conn.commit()

        cur.close()
        conn.close()
        return jsonify({'success': True})

    except Exception as e:
        return jsonify({'success': False, 'message': f'Error: {str(e)}'}), 500


@app.route('/admin/reviews')
def admin_reviews():
    if not session.get('logged_in') or session.get('user_type') != 'admin':
        return jsonify({'success': False, 'message': 'Unauthorized'})
    
    try:
        conn = connect_db()
        cur = conn.cursor()
        
        cur.execute("SELECT user_name FROM user_table WHERE user_id = %s", (session['user_id'],))
        admin_user = cur.fetchone()
        admin_name = admin_user[0] if admin_user else 'Admin'
        cur.execute("""
            SELECT r.review_id, rec.recipe_name, u.user_name, r.rating, 
                    r.comment, r.uploaded_time, r.user_id, r.recipe_id
            FROM review r
            JOIN recipe rec ON r.recipe_id = rec.recipe_id
            JOIN user_table u ON r.user_id = u.user_id
            ORDER BY r.uploaded_time DESC
        """)
        
        reviews_data = cur.fetchall()
        conn.close()
        
        reviews = []
        for row in reviews_data:
            reviews.append({
                'id': row[0],
                'recipe_name': row[1],
                'username': row[2],
                'rating': row[3],
                'comment': row[4],
                'date': row[5].strftime('%b %d, %Y'),
                'user_id': row[6],
                'recipe_id': row[7]
            })
        
        return render_template('admin_review.html', reviews=reviews, admin_name=admin_name)
        
    except Exception as e:
        print(f"Error: {str(e)}")
        return redirect(url_for('index'))

@app.route('/delete-review', methods=['POST'])
def delete_review():
    if not session.get('logged_in'):
        return jsonify({'success': False, 'message': 'Please log in to delete reviews'})
    try:
        data = request.get_json()
        recipe_id = data.get('recipe_id')
        user_id = data.get('user_id')

        if not recipe_id:
            return jsonify({'success': False, 'message': 'Recipe ID is required'})
        if session.get('user_type') != 'admin':
            user_id = session.get('user_id')

        conn = connect_db()
        cur = conn.cursor()
        cur.execute("CALL delete_review(%s, %s)", (user_id, recipe_id))
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({'success': True, 'message': 'Review deleted successfully'})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)})


if __name__ == '__main__':
    app.run(debug=True)

