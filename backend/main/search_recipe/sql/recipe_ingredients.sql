SELECT
    recipe_ingredient_id,
    recipe_ingredient_name,
    recipe_ingredient_amount,
    recipe_ingredient_unit,
    recipe_ingredient_calories
FROM recipe_ingredient
WHERE recipe_id = ?;
