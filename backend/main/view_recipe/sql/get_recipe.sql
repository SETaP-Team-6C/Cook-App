SELECT
    recipe.recipe_title,
    recipe.recipe_time,
    recipe.recipe_difficulty,
    recipe_step.recipe_step_id,
    recipe_step.recipe_step_index,
    recipe_step.recipe_step_description,
    recipe_step.recipe_step_duration,
    recipe_step_completion.user_id AS completed,
    recipe_ingredient.recipe_ingredient_id,
    recipe_ingredient.recipe_ingredient_name,
    recipe_ingredient.recipe_ingredient_amount,
    recipe_ingredient.recipe_ingredient_unit,
    recipe_ingredient.recipe_ingredient_calories
FROM recipe
LEFT JOIN recipe_step
    ON recipe.recipe_id = recipe_step.recipe_id
LEFT JOIN recipe_step_completion
    ON recipe_step.recipe_step_id = recipe_step_completion.recipe_step_id
    AND recipe_step_completion.user_id = ?
LEFT JOIN recipe_ingredient
    ON recipe.recipe_id = recipe_ingredient.recipe_id
WHERE recipe.recipe_id = ?
ORDER BY recipe_step.recipe_step_index, recipe_ingredient.recipe_ingredient_id;
