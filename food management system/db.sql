-- tables

-- 1)user_table
create table user_table (
user_id serial PRIMARY KEY,
user_name VARCHAR(100),
Email VARCHAR(255) UNIQUE NOT NULL,
passcode VARCHAR ,
phone_no VARCHAR(15) ,
category VARCHAR(50),
image varchar(1000000),
created_at timestamp 
);
select * from user_table;

-- 2)recipe table
CREATE TABLE recipe(
recipe_id SERIAL PRIMARY KEY,
user_id INT NOT NULL,
recipe_name VARCHAR(255) NOT NULL,
description VARCHAR(100000) NULL,
cooking_time INTEGER NOT NULL,
servings INT NOT NULL DEFAULT 2, 
image VARCHAR(5000) NOT NULL,
category VARCHAR(50) NOT NULL,
created_at TIMESTAMP ,
difficulty_level VARCHAR(10) not null,
status varchar(50),
rejection_reason varchar(1000),
FOREIGN KEY(user_id) REFERENCES user_table(user_id) ON DELETE CASCADE
);
select * from recipe;

-- 3)review table
CREATE TABLE review (
review_id serial PRIMARY KEY,
user_id INT NOT NULL,
recipe_id INT NOT NULL,
rating INT CHECK (rating BETWEEN 0 AND 5),
comment VARCHAR(10000),
uploaded_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY (user_id) REFERENCES user_table(user_id) ON DELETE CASCADE,
FOREIGN KEY (recipe_id) REFERENCES Recipe(Recipe_id) ON DELETE CASCADE
);
select * from review;

-- 4)ingredient table
create table ingredient(
ingredient_id serial PRIMARY KEY,
name VARCHAR(255) UNIQUE NOT NULL
);
select * from ingredient;

-- 5]recipe_ingredient table
create table recipe_ingredient(
recipe_id int not null,
ingredient_id int not null,
quantity decimal(10,2) not null check(quantity>0),
unit VARCHAR(50) NOT NULL,
primary key(recipe_id,ingredient_id),
foreign key (recipe_id) references recipe(recipe_id) on delete cascade,
foreign key (ingredient_id) references ingredient(ingredient_id) on delete cascade
);
select * from recipe_ingredient;


-- 6]instruction table
CREATE TABLE Instruction (
instruction_id serial NOT NULL primary key,
description VARCHAR(10000) NOT NULL
);
select * from Instruction;

-- 7]inst_ing_table
create table inst_ing_recipe(
inst_ing_recipe_id SERIAL PRIMARY KEY,
recipe_id INT NOT NULL,
step_no INT NOT NULL CHECK (step_no > 0),
instruction_id int not null,
ingredient_id int ,
used_quantity DECIMAL(10,2),
unit VARCHAR(50),
foreign key (recipe_id) references recipe(recipe_id) ,
foreign key (ingredient_id) references ingredient(ingredient_id) ,
foreign key (instruction_id) references Instruction(instruction_id)
);
select * from inst_ing_recipe;

-- 8]favorites table
CREATE TABLE favorites (
user_id INT NOT NULL,
recipe_id INT NOT NULL,
added_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
PRIMARY KEY (user_id, recipe_id),
FOREIGN KEY (user_id) REFERENCES user_table(user_id) ON DELETE CASCADE,
FOREIGN KEY (recipe_id) REFERENCES Recipe(Recipe_id) ON DELETE CASCADE
);
select * from favorites;


-- inputs

-- 1)inputs for user_table
INSERT INTO user_table (user_name, Email, passcode, phone_no, category) 
VALUES
('admin','admin@example.com','123456','57687970987', 'admin'),
('user','user@example.com','654321','57687977987','registered_user'),
('guest@example.com','guest'),
('AdminOne', 'admin1@example.com', 'admin123', '9998887771', 'admin'),
('ChefAnna', 'anna@example.com', 'cookitup', '8887776665', 'registered_user'),
('GuestJoe', 'guestjoe@example.com', 'guestpass', '7776665553', 'guest'),
('AdminTwo', 'admin2@example.com', 'secureme', '9998887772', 'admin'),
('FoodieMike', 'mike@example.com', 'yumyum12', '9876543210', 'registered_user'),
('GuestLily', 'lily.guest@example.com', 'guestlily', '9123456780', 'guest'),
('ChefRaj', 'raj.kitchen@example.com', 'masala45', '9781234567', 'registered_user'),
('AdminThree', 'admin3@example.com', 'strongpwd', '9988776655', 'admin'),
('GuestAmy', 'amy123@example.com', 'welcome', '9001122334', 'guest'),
('BakerTina', 'tina.bake@example.com', 'cakecake', '8899776655', 'registered_user'),
('GuestNick', 'nick.guest@example.com', 'nicky123', '9090909090', 'guest'),
('ChefKumar', 'kumar.cook@example.com', 'curry22', '9223344556', 'registered_user'),
('AdminFour', 'admin4@example.com', 'passadmin', '9111222333', 'admin'),
('GuestZara', 'zara.g@example.com', 'guestzara', '9345678123', 'guest'),
('ChefLena', 'lena.foodie@example.com', 'tasteit!', '9225566778', 'registered_user');

-- 2)recipe table inputs
INSERT INTO recipe (user_id, recipe_name, description, cooking_time, servings, image, category, difficulty_level) VALUES
(1,'panner butter masala','Rich and creamy North Indian dish...',45,4,'','Veg','Hard');
(4, 'Chana Masala', 'Spicy chickpea curry with Indian spices.', 35, 4, 'https://ministryofcurry.com/wp-content/uploads/2023/06/chana-masala_-5.jpg', 'Veg', 'Medium'),
(5, 'Grilled Chicken', 'Herb-marinated grilled chicken breast.', 30, 2, 'https://hips.hearstapps.com/hmg-prod/images/grilled-chicken-horizontal-1532030541.jpg', 'Non-veg', 'Easy'),
(7, 'Chocolate Brownies', 'Rich, fudgy brownies with a crackly top.', 45, 6, 'https://th.bing.com/th/id/OIP.Va7YrjzA3wAsNuDjQCeYcAHaHa?rs=1&pid=ImgDetMain', 'Desserts', 'Medium'),
(8, 'Aam Panna', 'Refreshing summer drink made with green mangoes.', 15, 3, 'https://th.bing.com/th/id/OIP.hxhXRKaDMJXJ3DBPdDb8QwHaLH?rs=1&pid=ImgDetMain', 'Drinks', 'Easy'),
(10, 'Matar Paneer', 'North Indian curry with green peas and paneer.', 40, 4, 'https://www.funfoodfrolic.com/wp-content/uploads/2022/03/Matar-Paneer-Blog.jpg', 'Veg', 'Medium'),
(11, 'Chicken Biryani', 'Aromatic basmati rice layered with spicy chicken.', 60, 4, 'https://feastwithsafiya.com/wp-content/uploads/2021/09/easy-chicken-biryani.jpg', 'Non-veg', 'Hard'),
(5, 'Fruit Custard', 'Chilled dessert made with fruits and creamy custard.', 20, 4, 'https://www.indianhealthyrecipes.com/wp-content/uploads/2021/05/fruit-custard-recipe.jpg', 'Desserts', 'Easy'),
(8, 'Masala Chai', 'Spiced Indian tea brewed with milk.', 10, 2, 'https://masalaandchai.com/wp-content/uploads/2021/07/Masala-Chai-Featured.jpg', 'Drinks', 'Easy'),
(14, 'Stuffed Capsicum', 'Bell peppers filled with spiced potatoes.', 35, 3, 'https://bellyfull.net/wp-content/uploads/2021/01/Stuffed-Peppers-blog-2-1536x2048.jpg', 'Veg', 'Medium'),
(4, 'Tandoori Chicken', 'Chicken marinated with yogurt and grilled.', 50, 4, 'https://th.bing.com/th/id/OIP.21xfGQ9jUczQhBfBTgASHwHaEJ?rs=1&pid=ImgDetMain', 'Non-veg', 'Hard'),
(13, 'Gulab Jamun', 'Deep-fried milk balls soaked in sugar syrup.', 45, 5, 'https://recipes.net/wp-content/uploads/2023/05/gulab-jamun-recipe_9fb159dc2674f395436a64666227c988-768x768.jpeg', 'Desserts','Medium');
(13, 'Rasmalai', 'Soft cottage cheese balls soaked in saffron milk.', 90, 5, 'https://th.bing.com/th/id/OIP.KJancznjSaFhw9BdwUPvxQHaLH?rs=1&pid=ImgDetMain', 'Desserts', 'Hard'),
(14, 'Cold Coffee', 'Chilled coffee blended with ice and cream.', 5, 2, 'https://th.bing.com/th/id/OIP.mdPvujEXvddWQzZFPIxf2gHaLH?rs=1&pid=ImgDetMain', 'Drinks', 'Easy'),
(16, 'Bhindi Masala', 'Spicy okra stir-fry.', 25, 3, 'https://th.bing.com/th/id/R.cde8bba585914c6fb9e67990be0cbcb6?rik=6tjLCdbs9LmDjQ&riu=http%3a%2f%2ffreeindianrecipes.com%2fwp-content%2fuploads%2fBhindi-Masala-Punjabi-Style-Recipe.jpg&ehk=1TTKEIHVvzLja4DZ30zbaKFCX3lf5TgmpV1pGepKAiY%3d&risl=&pid=ImgRaw&r=0', 'Veg', 'Easy'),
(18, 'Butter Garlic Prawns', 'Juicy prawns tossed in butter and garlic.', 20, 2, 'https://th.bing.com/th/id/OIP.-JzMsUszWuWEhX8depjVsAHaHa?rs=1&pid=ImgDetMain', 'Non-veg', 'Medium'),
(5, 'Fruit Custard', 'Chilled dessert made with fruits and creamy custard.', 20, 4, 'https://www.bing.com/images/search?view=detailV2&ccid=%2flEBJftq&id=F53014B4CA9CD88AEB359A7E64C437D11A948C29&thid=OIP._lEBJftqSsTAMbQ15szPoAHaFj&mediaurl=https%3a%2f%2fwww.indianhealthyrecipes.com%2fwp-content%2fuploads%2f2021%2f05%2ffruit-custard-recipe.jpg&exph=900&expw=1200&q=Fruit+Custard&simid=608010135751038900&FORM=IRPRST&ck=F95F7194047272DBB424431CB33E27A3&selectedIndex=2&itb=0', 'Desserts', 'Easy'),
(8, 'Masala Chai', 'Spiced Indian tea brewed with milk.', 10, 2, 'https://www.bing.com/images/search?view=detailV2&ccid=0vROkUlT&id=2CD4009DDDC72B907DC27A9F232C407775E4E270&thid=OIP.0vROkUlTg0zUeE-El_i-5gHaHa&mediaurl=https%3a%2f%2fcarameltintedlife.com%2fwp-content%2fuploads%2f2021%2f01%2fMasala-Chai-.jpg&exph=1200&expw=1200&q=Masala+Chai&simid=607995176373131787&FORM=IRPRST&ck=43864C5FC66F2A7FB1799DCE071A2A8E&selectedIndex=3&itb=0', 'Drinks', 'Easy'),
(14, 'Stuffed Capsicum', 'Bell peppers filled with spiced potatoes.', 35, 3, 'https://www.bing.com/images/search?view=detailV2&ccid=gaYvX7PS&id=4E01D07F016227BA3561299A8357AA4CCB8AC4DA&thid=OIP.gaYvX7PSbZUbU3yGQybsxAHaJ4&mediaurl=https%3a%2f%2fbellyfull.net%2fwp-content%2fuploads%2f2021%2f01%2fStuffed-Peppers-blog-2-1536x2048.jpg&exph=2048&expw=1536&q=Stuffed+Capsicum&simid=608017085000472002&FORM=IRPRST&ck=19C519A7FBE173A544D7EA4E9FC89B45&selectedIndex=3&itb=0', 'Veg', 'Medium'),
(4, 'Tandoori Chicken', 'Chicken marinated with yogurt and grilled.', 50, 4, 'https://www.bing.com/images/search?view=detailV2&ccid=21xfGQ9j&id=3BD9582DD91C86DE61C8769F1397F11636F5B6DB&thid=OIP.21xfGQ9jUczQhBfBTgASHwHaEJ&mediaurl=https%3a%2f%2fcdn.tasteatlas.com%2fimages%2fsocial%2f733cd5be69a84534b648fca6ef98b2a2.jpg&exph=2215&expw=3960&q=Tandoori+Chicken&simid=608038684356198712&FORM=IRPRST&ck=6BFFDA2E9952611706A8780CB3EEB8EE&selectedIndex=2&itb=0', 'Non-veg', 'Hard')
;


-- 3)review table inputs
INSERT INTO review (user_id, recipe_id, rating, comment) VALUES
(4, 2, 5, 'Amazing dish! The spaghetti was cooked perfectly, and the sauce was so flavorful. Definitely one of my favorites!'),
(5, 4, 4, 'The chicken curry was delicious, but it was a little spicier than expected. Still, very tasty!'),
(7, 13, 5, 'Best chocolate cake I’ve ever tasted! The texture was perfect, and the chocolate flavor was rich and decadent.'),
(8, 11, 3, 'The Caesar salad was fresh, but the dressing could use a little more flavor. Good for a light meal though.'),
(10, 12, 4, 'Miso soup was lovely. It could have used more tofu, but the seaweed and broth were great.'),
(11, 31, 5, 'Loved the tacos! They were perfectly seasoned and had the right amount of crunch.'),
(14, 30, 4, 'The butter chicken was creamy and flavorful, but I would have liked a bit more spice. Overall, a great dish.'),
(16, 29, 3, 'The Greek salad was good but lacked some seasoning. Feta cheese was perfect though.'),
(18, 32, 5, 'This recipe for Butter Chicken is amazing. The gravy was smooth and delicious, perfect with rice!'),
(19, 28, 4, 'The pancakes were nice and fluffy, but I felt like the syrup was a bit too sweet. Still enjoyed it a lot.');


-- 4]ingredient table inputs
INSERT INTO ingredient (name) VALUES
('Salt'),('Sugar'),('Flour'),('Eggs'),('Milk'),('Butter'),('Baking Powder'),('Vanilla Extract'),('Olive Oil'),('Garlic'),('Onion'),('Tomato'),
('Chicken Breast'),('Beef'),('Rice'),('Pasta'),('Cheese'),('Carrots'),('Potatoes'),('Spinach');('panner'),('spaghetti'), ('ground beef'),('bhindi'),('sugar'),('milk'),('coffee powder'),('chocolate'),('egg'),
('chicken'),('green mango'),('prawns'),('peas'),('custard powder'),('cardamom'),('ginger'),('garlic'),('tea leaves'),('capsicum'),('turmeric'),('chili powder'),
('coriander powder'),('cumin'),('mint leaves'),('lemon juice'),('rice');

-- 5]recipe_inredient inputs

-- Spaghetti Bolognese (recipe_id: 4)
INSERT INTO recipe_ingredient VALUES 
(4, 10, 200.00, 'grams'), -- spaghetti
(4, 11, 150.00, 'grams'), -- ground beef
(4, 5, 50.00, 'grams'),   -- onion
(4, 6, 80.00, 'grams'),   -- tomatoes
(4, 7, 1.00, 'tsp');      -- salt

-- Bhindi Masala (13)
INSERT INTO recipe_ingredient VALUES 
(13, 12, 200.00, 'grams'), -- bhindi
(13, 5, 60.00, 'grams'),   -- onion
(13, 6, 70.00, 'grams'),   -- tomatoes
(13, 20, 0.25, 'tsp'),     -- turmeric
(13, 7, 1.00, 'tsp');      -- salt

-- Rasmalai (11)
INSERT INTO recipe_ingredient VALUES 
(11, 1, 150.00, 'grams'),  -- paneer
(11, 14, 200.00, 'grams'), -- sugar
(11, 15, 300.00, 'ml'),    -- milk
(11, 22, 2.00, 'pods');    -- cardamom

-- Cold Coffee (12)
INSERT INTO recipe_ingredient VALUES 
(12, 16, 1.50, 'tbsp'),    -- coffee powder
(12, 15, 250.00, 'ml'),    -- milk
(12, 14, 1.00, 'tbsp');    -- sugar

-- Chocolate Brownies (31)
INSERT INTO recipe_ingredient VALUES 
(31, 17, 100.00, 'grams'), -- chocolate
(31, 18, 2.00, 'pcs'),     -- egg
(31, 14, 50.00, 'grams');  -- sugar

-- Grilled Chicken (30)
INSERT INTO recipe_ingredient VALUES 
(30, 19, 250.00, 'grams'), -- chicken
(30, 26, 1.00, 'tsp'),     -- chili powder
(30, 21, 1.00, 'tsp');     -- ginger

-- Chana Masala (29)
INSERT INTO recipe_ingredient VALUES 
(29, 6, 100.00, 'grams'),  -- tomatoes
(29, 5, 50.00, 'grams'),   -- onion
(29, 23, 1.00, 'tsp'),     -- cumin
(29, 26, 0.50, 'tsp');     -- chili powder

-- Aam Panna (32)
INSERT INTO recipe_ingredient VALUES 
(32, 20, 1.00, 'tsp'),     -- turmeric
(32, 13, 2.00, 'pcs'),     -- green mango
(32, 14, 2.00, 'tbsp');    -- sugar

-- Butter Garlic Prawns (28)
INSERT INTO recipe_ingredient VALUES 
(28, 2, 30.00, 'grams'),   -- butter
(28, 24, 1.00, 'tsp'),     -- garlic
(28, 21, 0.50, 'tsp'),     -- ginger
(28, 25, 200.00, 'grams'); -- prawns

-- Matar Paneer (33)
INSERT INTO recipe_ingredient VALUES 
(33, 1, 150.00, 'grams'),  -- paneer
(33, 5, 50.00, 'grams'),   -- onion
(33, 26, 0.50, 'tsp'),     -- chili powder
(33, 27, 100.00, 'grams'); -- peas

-- Fruit Custard (35)
INSERT INTO recipe_ingredient VALUES 
(35, 15, 250.00, 'ml'),    -- milk
(35, 14, 1.00, 'tbsp'),    -- sugar
(35, 21, 1.00, 'tbsp');   -- custard powder

-- Gulab Jamun (39)
INSERT INTO recipe_ingredient VALUES 
(39, 1, 100.00, 'grams'),  -- paneer
(39, 14, 150.00, 'grams'), -- sugar
(39, 22, 1.00, 'pod');     -- cardamom

-- Tandoori Chicken (38)
INSERT INTO recipe_ingredient VALUES 
(38, 19, 300.00, 'grams'), -- chicken
(38, 8, 0.50, 'tsp'),      -- garam-masala
(38, 26, 1.00, 'tsp');     -- chili powder

-- Chicken Biryani (34)
INSERT INTO recipe_ingredient VALUES 
(34, 19, 200.00, 'grams'), -- chicken
(34, 28, 100.00, 'grams'), -- rice
(34, 22, 2.00, 'pods'),    -- cardamom
(34, 23, 1.00, 'tsp'),     -- cumin
(34, 29, 10.00, 'leaves'); -- mint leaves

-- Masala Chai (36)
INSERT INTO recipe_ingredient VALUES 
(36, 15, 200.00, 'ml'),    -- milk
(36, 30, 1.00, 'tsp'),     -- tea leaves
(36, 22, 1.00, 'pod');     -- cardamom

-- Stuffed Capsicum (37)
INSERT INTO recipe_ingredient VALUES 
(37, 31, 2.00, 'pcs'),     -- capsicum
(37, 5, 30.00, 'grams'),   -- onion
(37, 7, 1.00, 'tsp');      -- salt


-- 6]instruction table inputs 
INSERT INTO Instruction (description)VALUES 
('Preheat oven to 180°C.'),
('Mix flour, sugar, and cocoa powder.'),
('Bake for 45 minutes.'),
('Season the chicken with spices.'),
('Grill for 30 minutes.'),
('chop'),
('bake'),
('preheat the oven'),                 
('grease the baking tray'),          
('whisk ingredients together'),     
('crush the spices'),                
('roast the spices'),                
('cool down completely'),            
('sauté onions until translucent'),  
('pressure cook for 2-3 whistles'),  
('add water and bring to boil'),    
('adjust seasoning as needed'),      
('serve chilled'),                  
('refrigerate before serving'),     
('grate the ingredient'),            
('sprinkle herbs on top'),           
('toast lightly before use'),        
('boil water'),               
('marinate the meat'),         
('mix well'),                  
('knead into soft dough'),     
('fry until golden brown'),    
('blend until smooth'),        
('soak in sugar syrup'),       
('strain the mixture'),        
('simmer on low flame'),       
('garnish and serve');         


-- 7] inst_ing_recipe table inputs 
-- 1. Paneer Butter Masala (recipe_id = 2)
INSERT INTO inst_ing_recipe VALUES
(1, 2, 1, 1, 1, 250.00, 'grams'),  -- add paneer
(2, 2, 2, 2, 2, 2.00, 'tbsp'),    -- add butter
(3, 2, 3, 3, 3, 1.00, 'tbsp'),    -- add oil
(4, 2, 4, 4, 4, 3.00, 'piece'),   -- add bay leaf
(5, 2, 5, 5, 5, 1.00, 'piece'),   -- add onion
(6, 2, 6, 6, 6, 3.00, 'piece'),   -- add tomatoes
(7, 2, 7, 7, 7, 2.00, 'tbsp'),    -- add salt
(8, 2, 8, 8, 8, 0.50, 'tsp'),     -- add garam masala
(9, 2, 9, 9, 9, 0.50, 'cup');     -- add cream

-- 2. Spaghetti Bolognese (recipe_id = 4)
INSERT INTO inst_ing_recipe VALUES  -- add minced meat
(11, 4, 2, 2, 5, 50.00, 'grams'),   -- add onion
(12, 4, 3, 3, 6, 80.00, 'grams'),   -- add carrots
(13, 4, 4, 4, 7, 1.00, 'tsp');      -- add salt
-- 3. Bhindi Masala (recipe_id = 13)
INSERT INTO inst_ing_recipe VALUES
(14, 13, 1, 1, 5, 60.00, 'grams'),  -- add onion
(15, 13, 2, 2, 6, 70.00, 'grams'),  -- add tomatoes
(16, 13, 3, 3, 20, 0.25, 'tsp'),    -- add turmeric
(17, 13, 4, 4, 7, 1.00, 'tsp');     -- add salt

-- 4. Rasmalai (recipe_id = 11)
INSERT INTO inst_ing_recipe VALUES
(18, 11, 1, 1, 1, 150.00, 'grams'), -- add milk
(19, 11, 2, 2, 14, 200.00, 'grams'), -- add rasgulla
(20, 11, 3, 3, 15, 300.00, 'ml'),   -- add cream
(21, 11, 4, 4, 22, 2.00, 'pods');   -- add cardamom

-- 5. Cold Coffee (recipe_id = 12)
INSERT INTO inst_ing_recipe VALUES
(22, 12, 1, 1, 16, 1.50, 'tbsp'),   -- add instant coffee
(23, 12, 2, 2, 15, 250.00, 'ml'),   -- add milk
(24, 12, 3, 3, 14, 1.00, 'tbsp');   -- add sugar

-- 6. Chocolate Brownies (recipe_id = 31)
INSERT INTO inst_ing_recipe VALUES
(25, 31, 1, 1, 17, 100.00, 'grams'), -- add flour
(26, 31, 2, 2, 18, 2.00, 'pcs'),    -- add eggs
(27, 31, 3, 3, 14, 50.00, 'grams');  -- add cocoa powder

-- 7. Grilled Chicken (recipe_id = 30)
INSERT INTO inst_ing_recipe VALUES
(28, 30, 1, 1, 19, 250.00, 'grams'), -- add chicken
(29, 30, 2, 2, 26, 1.00, 'tsp'),    -- add black pepper
(30, 30, 3, 3, 21, 1.00, 'tsp');    -- add salt

-- 8. Chana Masala (recipe_id = 29)
INSERT INTO inst_ing_recipe VALUES
(31, 29, 1, 1, 6, 100.00, 'grams'),  -- add chickpeas
(32, 29, 2, 2, 5, 50.00, 'grams'),   -- add onion
(33, 29, 3, 3, 23, 1.00, 'tsp'),     -- add cumin
(34, 29, 4, 4, 26, 0.50, 'tsp');     -- add turmeric

-- 9. Aam Panna (recipe_id = 32)
INSERT INTO inst_ing_recipe VALUES
(35, 32, 1, 1, 20, 1.00, 'tsp'),     -- add mint leaves
(36, 32, 2, 2, 13, 2.00, 'pcs'),     -- add mangoes
(37, 32, 3, 3, 14, 2.00, 'tbsp');    -- add sugar

-- 10. Butter Garlic Prawns (recipe_id = 28)
INSERT INTO inst_ing_recipe VALUES
(38, 28, 1, 1, 2, 30.00, 'grams'),   -- add butter
(39, 28, 2, 2, 24, 1.00, 'tsp'),     -- add garlic
(40, 28, 3, 3, 21, 0.50, 'tsp'),     -- add black pepper
(41, 28, 4, 4, 25, 200.00, 'grams'); -- add prawns

-- 11. Matar Paneer (recipe_id = 33)
INSERT INTO inst_ing_recipe VALUES
(42, 33, 1, 1, 1, 150.00, 'grams'),  -- add paneer
(43, 33, 2, 2, 5, 50.00, 'grams'),   -- add peas
(44, 33, 3, 3, 26, 0.50, 'tsp'),     -- add cumin
(45, 33, 4, 4, 27, 100.00, 'grams'); -- add tomatoes

-- 12. Fruit Custard (recipe_id = 35)
INSERT INTO inst_ing_recipe VALUES
(46, 35, 1, 1, 15, 250.00, 'ml'),    -- add milk
(47, 35, 2, 2, 14, 1.00, 'tbsp'),    -- add custard powder
(48, 35, 3, 3, 21, 1.00, 'tbsp');    -- add sugar

-- 13. Gulab Jamun (recipe_id = 39)
INSERT INTO inst_ing_recipe VALUES
(49, 39, 1, 1, 1, 100.00, 'grams'),  -- add milk powder
(50, 39, 2, 2, 14, 150.00, 'grams'), -- add ghee
(51, 39, 3, 3, 22, 1.00, 'pod');     -- add cardamom

-- 14. Tandoori Chicken (recipe_id = 38)
INSERT INTO inst_ing_recipe VALUES
(52, 38, 1, 1, 19, 300.00, 'grams'), -- add chicken
(53, 38, 2, 2, 8, 0.50, 'tsp'),      -- add turmeric
(54, 38, 3, 3, 26, 1.00, 'tsp');     -- add salt

-- 15. Chicken Biryani (recipe_id = 34)
INSERT INTO inst_ing_recipe VALUES
(55, 34, 1, 1, 19, 200.00, 'grams'), -- add chicken
(56, 34, 2, 2, 28, 100.00, 'grams'), -- add rice
(57, 34, 3, 3, 22, 2.00, 'pods'),    -- add cardamom
(58, 34, 4, 4, 23, 1.00, 'tsp'),     -- add cumin
(59, 34, 5, 5, 29, 10.00, 'leaves'); -- add mint leaves

-- 16. Masala Chai (recipe_id = 36)
INSERT INTO inst_ing_recipe VALUES
(60, 36, 1, 1, 15, 200.00, 'ml'),    -- add milk
(61, 36, 2, 2, 30, 1.00, 'tsp'),     -- add tea leaves
(62, 36, 3, 3, 22, 1.00, 'pod');     -- add cardamom

-- 17. Stuffed Capsicum (recipe_id = 37)
INSERT INTO inst_ing_recipe VALUES
(63, 37, 1, 1, 31, 2.00, 'pcs'),     -- add capsicum
(64, 37, 2, 2, 5, 30.00, 'grams'),   -- add onion
(65, 37, 3, 3, 7, 1.00, 'tsp');      -- add salt

--8]favorites table input
INSERT INTO favorites(user_id,recipe_id)
VALUES
(1,1),(4, 2),(5, 4), (7, 13), (8, 11),(10, 12),(11, 31),(13, 30),(14, 29),(16, 32),(18, 33), (4, 4),
(5, 11),(5, 12),(7, 31),(8, 28),(10, 39),(11, 38),(13, 33),(14, 36),(16, 37),(18, 30),(5, 39),(7, 4),
(8, 2),(10, 31),(11, 29),(13, 12),(14, 33); 


-- procedures
-- 1)insert guest user if not exists in user table
drop procedure insert_guest_user_if_not_exists;
CREATE OR REPLACE PROCEDURE insert_guest_user_if_not_exists(
    input_email VARCHAR,
    OUT inserted_user_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT user_id INTO inserted_user_id
    FROM user_table
    WHERE email = input_email;
    IF inserted_user_id IS NULL THEN
        INSERT INTO user_table (
            user_name,
            email,
            category
        )
        VALUES (
            CONCAT('Guest_', FLOOR(RANDOM() * 100000)), 
            input_email,
            'guest'
        );
    END IF;
END;
$$;
CALL insert_guest_user_if_not_exists('guestjohn@example.com',NULL);


-- 2) If a user registers, then it is updated in the user_table 
drop procedure register_user;
CREATE OR REPLACE PROCEDURE register_user(
    input_user_name VARCHAR,
    input_email VARCHAR,
    input_passcode VARCHAR,
    input_phone_no VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Check if user exists as a guest
    IF EXISTS (
        SELECT 1 FROM user_table
        WHERE email = input_email AND category = 'guest'
    ) THEN
        -- Update category as guest to registered_user
        UPDATE user_table
        SET user_name = input_user_name,
            passcode = input_passcode,
            phone_no = input_phone_no,
            category = 'registered_user'
        WHERE email = input_email;

    ELSE
        -- if not then Insert new registered user
        INSERT INTO user_table (user_name, email, passcode, phone_no, category)
        VALUES (input_user_name, input_email, input_passcode, input_phone_no, 'registered_user');
    END IF;
END;
$$;
CALL register_user('JohnRegistered','guestjohn@example.com','newsecurepass','9876543210');


-- 3]if the user adds a recipe to favorites then insert in favorites table 
drop procedure add_recipe_to_favorites;
CREATE OR REPLACE PROCEDURE add_recipe_to_favorites(
    p_user_id INT,
    p_recipe_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM favorites
        WHERE user_id = p_user_id AND recipe_id = p_recipe_id
    ) THEN
        -- If it exists already, remove it, i.e, unfavorite
        DELETE FROM favorites
        WHERE user_id = p_user_id AND recipe_id = p_recipe_id;

        RAISE NOTICE 'Recipe removed from favorites.';
    ELSE
        -- If it does not exist, insert it favorite table
        INSERT INTO favorites (user_id, recipe_id)
        VALUES (p_user_id, p_recipe_id);

        RAISE NOTICE 'Recipe added to favorites.';
    END IF;
END;
$$;
CALL add_recipe_to_favorites(5,11);


-- 4] Procedure to delete a review, both for a registered user for his review to delete and
--The Admin can delete any recipe
CREATE OR REPLACE PROCEDURE delete_review(
    p_user_id INT,
    p_recipe_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM review
    WHERE user_id = p_user_id AND recipe_id = p_recipe_id;
END;
$$;
call delete_review(5,2)

-- 5] Procedure for adding a recipe with the provided ingredients  
drop procedure add_recipe_with_ingredients;
CREATE OR REPLACE PROCEDURE add_recipe_with_ingredients(
    used_in INT,
    recipe_name TEXT,
    description TEXT,
    cooking_time INT,
    servings INT,
    image TEXT,
    category TEXT,
    difficulty_level TEXT,
    ingredient_names TEXT[],
    ingredient_quantities DECIMAL[],  
    ingredient_units TEXT[]          
)
LANGUAGE plpgsql AS $$
DECLARE
    new_recipe_id INT;
    ing_name TEXT;
    ing_qty DECIMAL;
    ing_unit TEXT;
    ing_id INT;
    i INT;
BEGIN
    -- Insert into recipe table with 'pending' status by default
    INSERT INTO recipe(
        user_id,
        recipe_name,
        description,
        cooking_time,
        servings,
        image,
        category,
        difficulty_level
    )
    VALUES (
        used_in,
        recipe_name,
        description,
        cooking_time,
        servings,
        image,
        category,
        difficulty_level
       
    )
    RETURNING recipe_id INTO new_recipe_id;

    -- Loop through ingredient arrays and add ingredients, regardless of status
    FOR i IN 1..array_length(ingredient_names, 1) LOOP
        ing_name := ingredient_names[i];
        ing_qty := ingredient_quantities[i];
        ing_unit := ingredient_units[i];

        -- see if ingredient exists
        SELECT ingredient_id INTO ing_id
        FROM ingredient
        WHERE name = ing_name;

        -- If the ingredient os not there or doesn't exist, then insert it
        IF NOT FOUND THEN
            INSERT INTO ingredient(name)
            VALUES (ing_name)
            RETURNING ingredient_id INTO ing_id;
        END IF;

        -- Insert into recipe_ingredient table
        INSERT INTO recipe_ingredient(recipe_id, ingredient_id, quantity, unit)
        VALUES (new_recipe_id, ing_id, ing_qty, ing_unit);
    END LOOP;

END;
$$;
CALL add_recipe_with_ingredients(
    4,  -- user_id (assuming user with ID 3 is adding this recipe)
    'Chocolate Cake',  -- Recipe name
    'A rich and moist chocolate cake, perfect for dessert lovers.',
    60,  -- cooking_time in minutes
    8,   -- servings
    'https://www.tasteofhome.com/wp-content/uploads/2017/10/Best-Chocolate-Cake_exps47786._THCA1917912C10_02_1bC_RMS-2.jpg',  -- Image URL
    'Dessert',  -- Category
    'Medium',  -- Difficulty level
    ARRAY['Flour', 'Cocoa Powder', 'Sugar', 'Eggs', 'Butter'],  -- Ingredient names
    ARRAY[250.00, 50.00, 200.00, 3.00, 100.00],  -- Quantities (grams or number of eggs)
    ARRAY['grams', 'grams', 'grams', 'pieces', 'grams']  -- Units (grams for dry ingredients, pieces for eggs)
);


-- 6]procedure for inserting the instructions with ingredients 
DROP PROCEDURE IF EXISTS into_inst_ing_recipe;
CREATE OR REPLACE PROCEDURE into_inst_ing_recipe(
    IN p_recipe_id INT,
    IN p_instructions TEXT[],
    IN p_ingredients TEXT[][],
    IN p_quantities DECIMAL(10,2)[][],
    IN p_units VARCHAR(50)[][]
)
LANGUAGE plpgsql
AS $$
DECLARE
    i INT;
    j INT;
    inst_id INT;
    ing_id INT;
    num_steps INT := array_length(p_instructions, 1);
    num_ings INT := array_length(p_ingredients, 2);
    inserted BOOLEAN;
BEGIN
    FOR i IN 1 .. num_steps LOOP
        inserted := FALSE;

        -- try to get the instruction_id from instruction table
        SELECT instruction_id INTO inst_id
        FROM instruction
        WHERE description = p_instructions[i];

        -- If that instruction is not found then insert it in the instructions table and get the id 
        IF NOT FOUND THEN
            INSERT INTO instruction(description) 
            VALUES (p_instructions[i]) 
            RETURNING instruction_id INTO inst_id;
            RAISE NOTICE 'Instruction "%" not found. Inserted with ID %.', p_instructions[i], inst_id;
        END IF;

        FOR j IN 1 .. num_ings LOOP
            IF p_ingredients[i][j] IS NULL THEN
                CONTINUE;
            END IF;

            -- now try to get ingredient_id from ingredient table
            SELECT ingredient_id INTO ing_id
            FROM ingredient
            WHERE name = p_ingredients[i][j];

            -- If the ingredient is not found in ingredient table, then insert it
            IF NOT FOUND THEN
                INSERT INTO ingredient(name)
                VALUES (p_ingredients[i][j])
                RETURNING ingredient_id INTO ing_id;
                RAISE NOTICE 'Ingredient "%" not found. Inserted with ID %.', p_ingredients[i][j], ing_id;
            END IF;

            -- now insert them into the inst_ing_recipe table
            INSERT INTO inst_ing_recipe (
                recipe_id, step_no, instruction_id, ingredient_id, used_quantity, unit
            )
            VALUES (
                p_recipe_id, i, inst_id, ing_id, p_quantities[i][j], p_units[i][j]
            );
            inserted := TRUE;
        END LOOP;

        -- If no ingredient was added for this instruction, insert using NULLs
        IF NOT inserted THEN
            INSERT INTO inst_ing_recipe (
                recipe_id, step_no, instruction_id, ingredient_id, used_quantity, unit
            )
            VALUES (
                p_recipe_id, i, inst_id, NULL, NULL, NULL
            );
        END IF;
    END LOOP;

    RAISE NOTICE 'Finished inserting for recipe_id %', p_recipe_id;
END;
$$;


CALL into_inst_ing_recipe(
    14,
    ARRAY[
        'Preheat oven to 180°C.',
        'Grill for 30 minutes.',
        'Bake for 45 minutes.'
    ],
    ARRAY[
        ARRAY['salt', NULL],
        ARRAY['Flour', 'Sugar'],
        ARRAY['cocoa powder', NULL]
    ],
    ARRAY[
        ARRAY[1.00, NULL],
        ARRAY[200.00, 100.00],
        ARRAY[1.00, NULL]
    ],
    ARRAY[
        ARRAY['unit', NULL],
        ARRAY['grams', 'grams'],
        ARRAY['portion', NULL]
    ]
);


-- 7]procedure for rejecting a recipe
drop procedure reject_recipe;
CREATE OR REPLACE PROCEDURE reject_recipe(recipe_to_reject INT, reason TEXT DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM inst_ing_recipe
    WHERE recipe_id = recipe_to_reject;

    DELETE FROM recipe_ingredient
    WHERE recipe_id = recipe_to_reject;

    DELETE FROM ingredient
    WHERE ingredient_id IN (
        SELECT i.ingredient_id
        FROM ingredient i
        LEFT JOIN recipe_ingredient ri ON i.ingredient_id = ri.ingredient_id
        WHERE ri.ingredient_id IS NULL
    );

	DELETE FROM favorites
    WHERE recipe_id = recipe_to_reject;

    DELETE FROM review
    WHERE recipe_id = recipe_to_reject;

    UPDATE recipe
    SET status = 'Rejected',
        rejection_reason = reason
    WHERE recipe_id = recipe_to_reject;
END;
$$;
call reject_recipe(20, 'Duplicate recipe with low-quality');

-- 8]if we delete user then it will delete all recipies also procedure
CREATE OR REPLACE PROCEDURE delete_user_and_all_recipes(user_to_delete INT)
LANGUAGE plpgsql
AS $$
DECLARE
    rec_id INT;
BEGIN

    IF NOT EXISTS (SELECT 1 FROM user_table WHERE user_id = user_to_delete) THEN
        RAISE EXCEPTION 'User with ID % does not exist.', user_to_delete;
    END IF;

    DELETE FROM review WHERE user_id = user_to_delete;
	
    DELETE FROM favorites WHERE user_id = user_to_delete;

    FOR rec_id IN
        SELECT recipe_id FROM recipe WHERE user_id = user_to_delete
    LOOP
        DELETE FROM inst_ing_recipe WHERE recipe_id = rec_id;
        DELETE FROM recipe_ingredient WHERE recipe_id = rec_id;
        DELETE FROM review WHERE recipe_id = rec_id;
        DELETE FROM favorites WHERE recipe_id = rec_id;
        DELETE FROM recipe WHERE recipe_id = rec_id;
    END LOOP;

    DELETE FROM user_table WHERE user_id = user_to_delete;

    RAISE NOTICE 'User % and all related data (recipes, ingredients, reviews, favorites) deleted.', user_to_delete;
END;
$$;
call delete_user_and_all_recipes(2);

-- 9]procedure if the user deletes a recipe
drop procedure delete_recipe_by_user;
CREATE OR REPLACE PROCEDURE delete_recipe_by_user(
    pre_user_id INT,
    recipe_to_delete INT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF NOT EXISTS (
        SELECT 1 FROM recipe
        WHERE recipe_id = recipe_to_delete AND user_id = pre_user_id
    ) THEN
        RAISE EXCEPTION 'Unauthorized: You do not own this recipe.';
    END IF;

    DELETE FROM inst_ing_recipe
    WHERE recipe_id = recipe_to_delete;

    DELETE FROM recipe_ingredient
    WHERE recipe_id = recipe_to_delete;

    DELETE FROM ingredient
    WHERE ingredient_id IN (
        SELECT i.ingredient_id
        FROM ingredient i
        LEFT JOIN recipe_ingredient ri ON i.ingredient_id = ri.ingredient_id
        WHERE ri.ingredient_id IS NULL
    );

    DELETE FROM favorites
    WHERE recipe_id = recipe_to_delete;

    DELETE FROM review
    WHERE recipe_id = recipe_to_delete;

    DELETE FROM recipe
    WHERE recipe_id = recipe_to_delete;
END;
$$;
call delete_recipe_by_user(5,2);


--10]delete any recipe by admin
CREATE OR REPLACE PROCEDURE delete_recipe_admin(
    recipe_to_delete INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM recipe WHERE recipe_id = recipe_to_delete
    ) THEN
        RAISE EXCEPTION 'Recipe not found.';
    END IF;

    DELETE FROM inst_ing_recipe
    WHERE recipe_id = recipe_to_delete;

    DELETE FROM recipe_ingredient
    WHERE recipe_id = recipe_to_delete;

    DELETE FROM ingredient
    WHERE ingredient_id IN (
        SELECT i.ingredient_id
        FROM ingredient i
        LEFT JOIN recipe_ingredient ri ON i.ingredient_id = ri.ingredient_id
        WHERE ri.ingredient_id IS NULL
    );

    DELETE FROM favorites
    WHERE recipe_id = recipe_to_delete;

    DELETE FROM review
    WHERE recipe_id = recipe_to_delete;

    DELETE FROM recipe
    WHERE recipe_id = recipe_to_delete;
END;
$$;


-- views
-- 1] view_recipes_by_avg_rating

drop view view_recipes_by_avg_rating;
CREATE OR REPLACE VIEW view_recipes_by_avg_rating AS
SELECT 
    r.recipe_name,
    r.category,
    ROUND(AVG(rv.rating)::NUMERIC, 2) AS average_rating,
    r.cooking_time,
    r.servings,
    r.image,
	r.recipe_id
FROM Recipe r
LEFT JOIN review rv ON rv.recipe_id = r.recipe_id
where r.status='Approved'
GROUP BY r.recipe_id
ORDER BY average_rating desc nulls last;
select * from view_recipes_by_avg_rating;

-- 2]view_user_favorites

drop view view_user_favorites;
CREATE OR REPLACE VIEW view_user_favorites AS
SELECT 
	f.user_id,
    r.recipe_name,
	r.image,
    r.category,
    r.cooking_time,
    f.added_on
FROM favorites f
JOIN recipe r ON f.recipe_id=r.recipe_id;
select * from view_user_favorites where user_id=11;


-- 3]view_user_profile_details
select * from user_table;
drop view  view_user_profile_details;
CREATE OR REPLACE VIEW view_user_profile_details AS

SELECT 
    u.user_id,
    u.user_name,
    u.image,
    TO_CHAR(u.created_at, 'DD-MM-YYYY') AS joined_on,
    (SELECT COUNT(*) FROM recipe r1 WHERE r1.user_id = u.user_id) AS total_recipes_created,
    (SELECT COUNT(*) FROM favorites f1 WHERE f1.user_id = u.user_id) AS total_favorites,
    NULL::INTEGER AS recipe_id,
    NULL::TEXT AS recipe_name,
    NULL::TEXT AS recipe_image,
    NULL::TEXT AS category,
    NULL::INTEGER AS cooking_time,
    NULL::INTEGER AS favorite_count,
    NULL::TEXT AS recipe_type,
    NULL::TEXT AS status,
    NULL::TEXT AS rejection_reason
FROM user_table u
WHERE u.category != 'guest'

UNION ALL

SELECT 
    u.user_id,
    u.user_name,
    u.image,
    TO_CHAR(u.created_at, 'DD-MM-YYYY') AS joined_on,
    (SELECT COUNT(*) FROM recipe r1 WHERE r1.user_id = u.user_id),
    (SELECT COUNT(*) FROM favorites f1 WHERE f1.user_id = u.user_id),
    r.recipe_id,
    r.recipe_name,
    r.image AS recipe_image,
    r.category,
    r.cooking_time,
    count_favorites_for_recipe(r.recipe_id),
    'created',
    r.status,
    NULL::TEXT
FROM user_table u
JOIN recipe r ON r.user_id = u.user_id
WHERE r.status IS DISTINCT FROM 'Rejected'
  AND u.category != 'guest'

UNION ALL

SELECT 
    u.user_id,
    u.user_name,
    u.image,
    TO_CHAR(u.created_at, 'DD-MM-YYYY') AS joined_on,
    (SELECT COUNT(*) FROM recipe r1 WHERE r1.user_id = u.user_id),
    (SELECT COUNT(*) FROM favorites f1 WHERE f1.user_id = u.user_id),
    r2.recipe_id,
    r2.recipe_name,
    r2.image AS recipe_image,
    r2.category,
    r2.cooking_time,
    NULL::INTEGER,
    'favorite',
    NULL::VARCHAR(50),
    NULL::TEXT
FROM user_table u
JOIN favorites f2 ON f2.user_id = u.user_id
JOIN recipe r2 ON f2.recipe_id = r2.recipe_id
WHERE u.category != 'guest'

UNION ALL

SELECT 
    u.user_id,
    u.user_name,
    u.image,
    TO_CHAR(u.created_at, 'DD-MM-YYYY') AS joined_on,
    (SELECT COUNT(*) FROM recipe r1 WHERE r1.user_id = u.user_id),
    (SELECT COUNT(*) FROM favorites f1 WHERE f1.user_id = u.user_id),
    r3.recipe_id,
    r3.recipe_name,
    r3.image AS recipe_image,
    r3.category,
    r3.cooking_time,
    NULL::INTEGER,
    'rejected',
    r3.status,
    r3.rejection_reason
FROM user_table u
JOIN recipe r3 ON r3.user_id = u.user_id
WHERE r3.status = 'Rejected'
  AND u.category != 'guest';


-- functions

-- 1]function for getting the getting the recipe ingredients details
drop function get_recipe_ingredient_details;
CREATE OR REPLACE FUNCTION get_recipe_ingredient_details(input_recipe_id int)
RETURNS TABLE (
    recipe_name VARCHAR,
    image VARCHAR,
	description VARCHAR,
	cooking_time INT,
    servings INT,
	category VARCHAR,
	difficulty_level VARCHAR,
    user_name VARCHAR,
    ingredient_name VARCHAR,
    quantity DECIMAL,
    unit VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.recipe_name,
        r.Image,
		r.description,
		r.cooking_time,
        r.servings,
		r.category,
		r.difficulty_level,
        u.user_name,
        i.name AS ingredient_name,
        ri.quantity,
        ri.unit
    FROM recipe r
    JOIN user_table u ON u.user_id = r.user_id
    LEFT JOIN recipe_ingredient ri ON ri.recipe_id = r.recipe_id
    LEFT JOIN ingredient i ON i.ingredient_id = ri.ingredient_id
    WHERE r.recipe_id = input_recipe_id;
END;
$$
language plpgsql;
select * from get_recipe_ingredient_details('4');


-- 2]functions for getting the recipe instruction details
drop function get_recipe_instruction_details;
CREATE OR REPLACE FUNCTION get_recipe_instruction_details(input_recipe_id int)
RETURNS TABLE (
	recipe_name VARCHAR,
    instruction VARCHAR,
	ingredient_name VARCHAR,
	used_quantity decimal,
	step_no integer,
	unit varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
		recipe.recipe_name,
        Instruction.description as instruction,
		ingredient.name as ingredient_name,
		inst_ing_recipe.used_quantity,
		inst_ing_recipe.step_no,
		inst_ing_recipe.unit 
    FROM Instruction
    JOIN inst_ing_recipe on inst_ing_recipe.instruction_id =instruction.instruction_id
    JOIN recipe ON recipe.recipe_id =inst_ing_recipe.recipe_id
    JOIN ingredient ON ingredient.ingredient_id = inst_ing_recipe.ingredient_id
    WHERE recipe.recipe_id = input_recipe_id
	order by step_no;
END;
$$ LANGUAGE plpgsql;
SELECT * FROM get_recipe_instruction_details('9');


-- 3]function for getting the recipe review details
drop function  get_recipe_review_details;
CREATE OR REPLACE FUNCTION get_recipe_review_details(input_recipe_id int)
RETURNS TABLE (
	recipe_id int,
    user_name VARCHAR,
	comment varchar,
	rating int,
	user_id int,
	uploaded_at TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
		review.recipe_id,
       	user_table.user_name, 
		review.comment,
		review.rating,
		user_table.user_id,
		CASE
            WHEN now()::date = review.uploaded_time::date THEN
                'Today'
            WHEN now() - review.uploaded_time < interval '1 day' THEN
                'Less than a day ago'
            WHEN now() - review.uploaded_time < interval '2 days' THEN
                '1 day ago'
            ELSE
                concat(EXTRACT(day FROM now() - review.uploaded_time)::int, ' days ago')
        END as uploaded_at
	FROM recipe
    left JOIN review ON review.recipe_id = recipe.recipe_id
    left JOIN user_table ON review.user_id = user_table.user_id
    WHERE recipe.recipe_id = input_recipe_id
	ORDER BY uploaded_at desc nulls last;
END;
$$ LANGUAGE plpgsql;
SELECT * FROM get_recipe_review_details('9');


-- 4]function for getting the recommended recipes by category rating 
drop function recommend_recipes_by_category_rating;
CREATE OR REPLACE FUNCTION recommend_recipes_by_category_rating(input_recipe_id int, limit_count INT DEFAULT 5)
RETURNS TABLE (
    recommended_recipe_name VARCHAR,
    category VARCHAR,
	image varchar,
	cooking_time int,
    avg_rating NUMERIC(3,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r2.recipe_name as recommended_recipe_name,
        r2.category,
		r2.image,
		r2.cooking_time,
        r2.average_rating as avg_rating
    FROM view_recipes_by_avg_rating r1
    JOIN view_recipes_by_avg_rating r2 ON r1.category = r2.category
    WHERE r1.recipe_id = input_recipe_id
      AND r2.recipe_id <> input_recipe_id
    ORDER BY r2.average_rating DESC NULLS LAST
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;
select * from recommend_recipes_by_category_rating('14');


-- 5]function for counting the number of favotites for a recipe
CREATE OR REPLACE FUNCTION count_favorites_for_recipe(input_recipe_id INT)
RETURNS INT AS $$
DECLARE
    fav_count INT;
BEGIN
    SELECT COUNT(*) INTO fav_count
    FROM favorites
    WHERE recipe_id = input_recipe_id;

    RETURN fav_count;
END;
$$ LANGUAGE plpgsql;
select * from count_favorites_for_recipe(1);


-- 6]function for updating the review
drop function update_review;
CREATE OR REPLACE FUNCTION update_review(
    p_user_id INT,
    p_recipe_id INT,
    p_rating INT,
    p_comment TEXT
) RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM review
        WHERE user_id = p_user_id AND recipe_id = p_recipe_id
    ) THEN
        UPDATE review
        SET comment = p_comment,
            rating = p_rating
        WHERE user_id = p_user_id AND recipe_id = p_recipe_id;
    ELSE
        INSERT INTO review (user_id, recipe_id, comment, rating)
        VALUES (p_user_id, p_recipe_id, p_comment, p_rating);
    END IF;
END;
$$;



-- triggers

-- 1] trigger for a recipe to have cooking time >2 and servings atleat 1
CREATE OR REPLACE FUNCTION validate_recipe_constraints()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.cooking_time < 2 THEN
        RAISE EXCEPTION 'Cooking time must be at least 2 minutes.';
    END IF;
    IF NEW.servings < 1 THEN
        RAISE EXCEPTION 'Servings must be at least 1.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_validate_recipe
BEFORE INSERT ON Recipe
FOR EACH ROW
EXECUTE FUNCTION validate_recipe_constraints();


-- 2]as the user adds the recipe it should go to pending 
drop trigger trigger_set_default_status on recipe;
drop function set_default_recipe_status;
CREATE OR REPLACE FUNCTION set_default_recipe_status()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status IS NULL THEN
        NEW.status := 'Pending';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_set_default_status
BEFORE INSERT ON Recipe
FOR EACH ROW
EXECUTE FUNCTION set_default_recipe_status();


-- 3]set recipe created at trigger
CREATE OR REPLACE FUNCTION set_created_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.created_at := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_set_created_at_recipe
BEFORE INSERT ON recipe
FOR EACH ROW
EXECUTE FUNCTION set_created_at();

-- 4]set user created at trigger
drop trigger trigger_set_created_at_user on user_table;
drop function set_uploaded_user_at;
CREATE OR REPLACE FUNCTION set_uploaded_user_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.created_at := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_set_created_at_user
BEFORE INSERT ON user_table
FOR EACH ROW
EXECUTE FUNCTION set_uploaded_user_at();

-- 5]set review created at trigger
drop trigger trigger_set_created_at_review on review;
CREATE OR REPLACE FUNCTION set_review_uploaded_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.uploaded_time := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER trigger_set_created_at_review
BEFORE INSERT ON review
FOR EACH ROW
EXECUTE FUNCTION set_review_uploaded_at();
select * from review;
select * from recipe;


6] ----
drop trigger trigger_validate_recipe_ingredients on recipe;
drop function  validate_recipe_ingredients;
CREATE OR REPLACE FUNCTION validate_recipe_ingredients()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM recipe_ingredient
        WHERE recipe_id = NEW.recipe_id
    ) THEN
        RAISE EXCEPTION 'ingredients must be at least 1';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_validate_recipe_ingredients
after INSERT ON recipe
FOR EACH ROW
EXECUTE FUNCTION validate_recipe_ingredients();


7]--
drop function check_total_used_quantity;
drop trigger check_total_used_quantity_trigger on inst_ing_recipe;

CREATE OR REPLACE FUNCTION check_total_used_quantity()
RETURNS TRIGGER AS $$
DECLARE
    total_used DECIMAL(10,2);
    available_quantity DECIMAL(10,2);
    ingredient_name VARCHAR(255);
BEGIN
    IF NEW.ingredient_id IS NULL OR NEW.used_quantity IS NULL THEN
        RETURN NEW;
    END IF;

    SELECT name INTO ingredient_name
    FROM ingredient
    WHERE ingredient_id = NEW.ingredient_id;

    SELECT quantity INTO available_quantity
    FROM recipe_ingredient
    WHERE recipe_id = NEW.recipe_id AND ingredient_id = NEW.ingredient_id;

    IF available_quantity IS NULL THEN
        RAISE EXCEPTION 'Ingredient "%" (ID: %) is not listed in the recipe ingredients. Please add it to recipe_ingredient first.',
            ingredient_name, NEW.ingredient_id;
    END IF;

    SELECT COALESCE(SUM(used_quantity), 0) INTO total_used
    FROM inst_ing_recipe
    WHERE recipe_id = NEW.recipe_id 
      AND ingredient_id = NEW.ingredient_id
      AND inst_ing_recipe_id != NEW.inst_ing_recipe_id;

    total_used := total_used + NEW.used_quantity;
    IF total_used > available_quantity THEN
        RAISE EXCEPTION 'Cannot use % %s of "%" - only % %s available. Total used (%) would exceed available quantity.',
    		NEW.used_quantity, NEW.unit, ingredient_name, available_quantity, NEW.unit, total_used;
    END IF;

    IF NEW.used_quantity <= 0 THEN
        RAISE EXCEPTION 'Used quantity for ingredient "%" must be greater than 0.',
            ingredient_name;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_total_used_quantity_trigger
BEFORE INSERT OR UPDATE ON inst_ing_recipe
FOR EACH ROW
EXECUTE FUNCTION check_total_used_quantity();
select * from recipe;
UPDATE recipe
SET status = 'Rejected'
WHERE recipe_id = 202;


-- 8]trigger for checking the difficulty level
drop trigger check_difficulty_level_before_insert on recipe;
drop function check_difficulty_level;
CREATE OR REPLACE FUNCTION check_difficulty_level()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.difficulty_level NOT IN ('Easy', 'Medium', 'Hard') THEN
        RAISE EXCEPTION 'Invalid difficulty level: %. Must be "Easy", "Medium", or "Hard".', NEW.difficulty_level;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_difficulty_level_before_insert
BEFORE INSERT ON recipe
FOR EACH ROW
EXECUTE FUNCTION check_difficulty_level();


-- 9] check that for each ingredient quantity is >0
drop trigger check_ingredient_quantity_before_insert on inst_ing_recipe;
drop function check_ingredient_quantity;

CREATE OR REPLACE FUNCTION check_ingredient_quantity()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.ingredient_id IS NOT NULL THEN
        IF NEW.used_quantity<=0 THEN
            RAISE EXCEPTION 'Ingredient quantity must be greater than 0. Ingredient ID: %', NEW.ingredient_id;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_ingredient_quantity_before_insert
BEFORE INSERT ON inst_ing_recipe
FOR EACH ROW
EXECUTE FUNCTION check_ingredient_quantity();


-- indexes
drop index unique_user_recipe_rating;
CREATE UNIQUE INDEX unique_user_recipe_rating
ON review (user_id,recipe_id);
INSERT INTO review (user_id, recipe_id, rating, comment) VALUES
(5,4, 4, 'Tasty tacos with just the right amount of spice.');

-- Index on created_at if you sort or filter by join date
CREATE INDEX idx_user_created_at ON user_table(created_at);
SET enable_seqscan TO off;
explain analyze
SELECT * FROM user_table ORDER BY created_at DESC;
SET enable_seqscan TO on;  -- Re-enable sequential scan


-- Index on user_id to fetch user’s recipes
CREATE INDEX idx_recipe_user_id ON recipe(user_id);
explain analyze
SELECT * FROM recipe WHERE user_id = 5;


-- Index on category if users filter by category
CREATE INDEX idx_recipe_category ON recipe(category);
explain analyze
SELECT * FROM recipe WHERE category = 'Veg';


-- Index on status for moderation or filtering approved/rejected recipes
CREATE INDEX idx_recipe_status ON recipe(status);
explain analyze
SELECT * FROM recipe WHERE status = 'Pending';


-- Composite index for user and status together
CREATE INDEX idx_recipe_user_status ON recipe(user_id, status);
explain analyze
SELECT * FROM recipe
WHERE user_id = 5 AND status = 'Approved';


-- Index on recipe_id to fetch reviews per recipe
CREATE INDEX idx_review_recipe_id ON review(recipe_id);
explain analyze
SELECT * FROM review WHERE recipe_id = 42;

-- Index on user_id if you fetch all reviews by a user
CREATE INDEX idx_review_user_id ON review(user_id);
explain analyze
SELECT * FROM review WHERE user_id = 10;


-- Index on ingredient name for searching or filtering
CREATE INDEX idx_ingredient_name ON ingredient(name);
explain analyze
SELECT * FROM ingredient WHERE name='Sugar';


CREATE INDEX idx_recipe_id ON recipe_ingredient(recipe_id);
explain analyze
SELECT * FROM recipe_ingredient WHERE recipe_id = 12;


-- Index on description for lookup or search
CREATE INDEX idx_instruction_desc ON instruction(description);
explain analyze
SELECT instruction_id FROM instruction WHERE description = 'Boil pasta until al dente';


-- Composite index on foreign keys
CREATE INDEX idx_inst_ing_recipe ON inst_ing_recipe(recipe_id,instruction_id, ingredient_id);
explain analyze
SELECT instruction.description, ingredient.name
FROM instruction
JOIN inst_ing_recipe ON inst_ing_recipe.instruction_id = instruction.instruction_id
JOIN ingredient ON inst_ing_recipe.ingredient_id = ingredient.ingredient_id
WHERE inst_ing_recipe.recipe_id = 4 and inst_ing_recipe.instruction_id=2 and inst_ing_recipe.ingredient_id=5;

-- Index on recipe_id to get favorite count per recipe
CREATE INDEX idx_favorites_recipe_id ON favorites(recipe_id);
explain analyze
SELECT COUNT(*) FROM favorites WHERE recipe_id = 22;

-- Index on user_id to get user’s favorite list
CREATE INDEX idx_favorites_user_id ON favorites(user_id);
explain analyze
SELECT * FROM favorites WHERE user_id = 7;


CREATE UNIQUE INDEX idx_unique_user_recipe
ON recipe(user_id,recipe_name);
INSERT INTO recipe (user_id, recipe_name, description, cooking_time, servings, image, category, created_at, difficulty_level)
VALUES (4,'Spaghetti Bolognese', 'Classic Italian pasta with rich meat sauce.', 45, 4, 'https://th.bing.com/th/id/R.a6d6e24b2c5b813d6609cf4d1b6fd9f5?rik=FNJbix5MuysM4A&riu=http%3a%2f%2fwww.thefoodjoy.com%2fwp-content%2fuploads%2f2019%2f07%2fpasta-bolognese-2.jpg&ehk=JZg%2b%2f0YfHKQpmQ17%2ftMsdNrxbuYWTwtDpUO1w%2fQ%2bk%2bs%3d&risl=&pid=ImgRaw&r=0', 'Veg', '2025-04-24 22:34:17.340954', 'Medium');


-- queries

-- 1]
set role Admin;
SELECT u.user_id, u.user_name, u.email, u.category, u.created_at,
        COUNT(DISTINCT r.recipe_id) as recipe_count
        FROM user_table u
        LEFT JOIN recipe r ON u.user_id = r.user_id
        GROUP BY u.user_id, u.user_name, u.Email, u.category, u.created_at
        ORDER BY u.created_at DESC;

-- 2]
SELECT r.recipe_name, u.user_name, r.category, r.created_at, r.status
            FROM recipe r
            JOIN user_table u ON r.user_id = u.user_id
            WHERE r.status = 'pending'
            ORDER BY r.created_at DESC;


-- 3]
SELECT r.recipe_name, u.user_name, r.category, r.created_at, r.status
            FROM recipe r
            JOIN user_table u ON r.user_id = u.user_id
            ORDER BY r.created_at DESC;

-- 4]
SELECT r.review_id, rec.recipe_name, u.user_name, r.rating, 
                    r.comment, r.uploaded_time
            FROM review r
            JOIN recipe rec ON r.recipe_id = rec.recipe_id
            JOIN user_table u ON r.user_id = u.user_id
            ORDER BY r.uploaded_time DESC;
			
--5)
set role registered_user;
select * from view_user_favorites where user_id=5;

--6)
select * from view_user_profile_details where user_id=5;

--7)
set role guest;
select * from view_recipes_by_avg_rating;

-- Roles
-- Create Admin role
CREATE ROLE admin WITH SUPERUSER LOGIN PASSWORD 'admin_pass';
-- Grant privileges to the Admin role (full access to everything)
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO admin;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO admin;

-- Create registered_user role
CREATE ROLE registered_user WITH LOGIN PASSWORD 'user_pass';
-- Grant privileges to the Regular User role
GRANT INSERT, DELETE, SELECT, UPDATE ON recipe TO registered_user;   
GRANT INSERT, DELETE ON review TO registered_user;                     
GRANT SELECT, INSERT, DELETE ON favorites TO registered_user;                         
GRANT SELECT ON recipe, review, ingredient, instruction TO registered_user; 
GRANT EXECUTE ON FUNCTION get_recipe_ingredient_details TO registered_user;
GRANT EXECUTE ON FUNCTION get_recipe_instruction_details TO registered_user;
GRANT EXECUTE ON FUNCTION get_recipe_review_details TO registered_user;
GRANT EXECUTE ON FUNCTION update_review TO registered_user;
GRANT EXECUTE ON PROCEDURE add_recipe_to_favorites TO registered_user;
GRANT EXECUTE ON PROCEDURE delete_review TO registered_user;
GRANT EXECUTE ON PROCEDURE add_recipe_with_ingredients TO registered_user;
GRANT EXECUTE ON PROCEDURE into_inst_ing_recipe TO registered_user;
GRANT EXECUTE ON PROCEDURE delete_recipe_by_user TO registered_user;
GRANT SELECT ON view_user_profile_details TO registered_user;
GRANT SELECT ON view_user_favorites TO registered_user;
GRANT SELECT ON view_recipes_by_avg_rating TO registered_user;


-- Create Guest role
CREATE ROLE guest WITH LOGIN PASSWORD 'guest_pass';
-- Grant privileges to Guest role
GRANT SELECT ON recipe, review TO guest; 
GRANT SELECT ON view_recipes_by_avg_rating TO guest;
GRANT EXECUTE ON FUNCTION get_recipe_review_details TO guest;
GRANT EXECUTE ON FUNCTION get_recipe_ingredient_details TO guest;
GRANT EXECUTE ON FUNCTION get_recipe_instruction_details TO guest;




