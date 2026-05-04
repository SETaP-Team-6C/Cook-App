SELECT
    rs.recipe_step_id AS "recipe-step-id",
    rs.recipe_step_description AS "step-description",
    rs.recipe_step_duration AS "step-duration",
    rs.recipe_step_index as "step-index",
    CASE
        WHEN EXISTS
            (
                SELECT 1
                FROM
                    recipe_step_completion rsc
                WHERE
                    rsc.recipe_step_id = rs.recipe_step_id AND rsc.user_id = ?2
            )
            THEN 1
            ELSE 0
        END AS "step-completion"
FROM
    recipe_step rs
WHERE
    rs.recipe_id = ?1;
