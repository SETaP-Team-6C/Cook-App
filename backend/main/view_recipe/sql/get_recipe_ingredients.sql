SELECT
    recipe_ingredient_name AS "ingredient-name",
    recipe_ingredient_amount AS "ingredient-amount",
    recipe_ingredient_unit AS "ingredient-unit",
    recipe_ingredient_calories as "ingredient-calories"
FROM
    recipe_ingredient
WHERE
    recipe_id = ?