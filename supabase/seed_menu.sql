-- ============================================================================
-- OPTIONAL reference seed. The menu is already fixed in the app (index.html),
-- so the website does not require this. It's handy if you later want to drive
-- the cards from the database or keep the menu in one queryable place.
-- Run in: SQL Editor -> New query -> Run
-- ============================================================================
delete from public.menu_options;
insert into public.menu_options (category, label, subtitle, subtitle_id, emoji, image_url, sort) values
 ('main','Salmon Wellington','puff pastry · spinach · lemon butter · roast veg','puff pastry · bayam · lemon butter · sayur panggang','🐟','assets/th_salmon.jpg',1),
 ('main','Grill Chicken','rich creamy mushroom sauce','saus jamur krim yang kaya','🍗','assets/th_grillchicken.jpg',2),
 ('main','48hr Beef Rendang Short Ribs','slow-cooked · Indonesian spice · mashed potato','dimasak perlahan · bumbu Nusantara · kentang tumbuk','🥩','assets/th_beef.jpg',3),
 ('main','Chicken Pop','coconut-poached · sambal pop · mashed potato','rebusan air kelapa · sambal pop · kentang tumbuk','🥥','assets/th_chickenpop.jpg',4),
 ('dessert','New York Cheesecake','vanilla · buttery graham crust','vanila · kerak graham mentega','🍰','assets/th_ny.jpg',1),
 ('dessert','Devil Cake','dark chocolate · silky ganache','cokelat pekat · ganache lembut','🍫','assets/th_devil.jpg',2),
 ('dessert','Pulut Cake','coconut sticky rice · srikaya jam','ketan santan · selai srikaya','🍮','assets/th_pulut.jpg',3),
 ('beverage','Alcoholic',null,null,'🍷',null,1),
 ('beverage','Non-Alcoholic',null,null,'🧃',null,2);
