SELECT
    user_id, user_password
FROM
    user
WHERE
    -- Comparison is case-insensitive!
    user_fname like ? AND user_lname like ?
limit 1;
