SELECT
    c_name,
    c_address,
    c_nationkey + 1
FROM
    customer
WHERE
    c_nationkey = 5;