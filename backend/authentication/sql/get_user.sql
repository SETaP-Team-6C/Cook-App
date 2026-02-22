SELECT
    user_id
FROM
    user
WHERE
    user_fname = ? AND user_lname = ?
limit 1;
