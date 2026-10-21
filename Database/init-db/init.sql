-- MARK: TYPES
-- ████████╗██╗░░░██╗██████╗░███████╗░██████╗
-- ╚══██╔══╝╚██╗░██╔╝██╔══██╗██╔════╝██╔════╝
-- ░░░██║░░░░╚████╔╝░██████╔╝█████╗░░╚█████╗░
-- ░░░██║░░░░░╚██╔╝░░██╔═══╝░██╔══╝░░░╚═══██╗
-- ░░░██║░░░░░░██║░░░██║░░░░░███████╗██████╔╝
-- ░░░╚═╝░░░░░░╚═╝░░░╚═╝░░░░░╚══════╝╚═════╝░

CREATE TYPE Type AS ENUM (
    'Normal',
    'Fire',
    'Water',
    'Grass',
    'Electric',
    'Ice',
    'Fighting',
    'Poison',
    'Ground',
    'Flying',
    'Psychic',
    'Bug',
    'Rock',
    'Ghost',
    'Dragon',
    'Dark',
    'Steel',
    'Fairy'
);

-- MARK: TABLES
-- ████████╗░█████╗░██████╗░██╗░░░░░███████╗░██████╗
-- ╚══██╔══╝██╔══██╗██╔══██╗██║░░░░░██╔════╝██╔════╝
-- ░░░██║░░░███████║██████╦╝██║░░░░░█████╗░░╚█████╗░
-- ░░░██║░░░██╔══██║██╔══██╗██║░░░░░██╔══╝░░░╚═══██╗
-- ░░░██║░░░██║░░██║██████╦╝███████╗███████╗██████╔╝
-- ░░░╚═╝░░░╚═╝░░╚═╝╚═════╝░╚══════╝╚══════╝╚═════╝░

CREATE TABLE IF NOT EXISTS Pokemon (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type1 Type NOT NULL,
    type2 Type,
    height DOUBLE PRECISION NOT NULL,
    weight DOUBLE PRECISION NOT NULL,
    liked BOOLEAN NOT NULL DEFAULT FALSE,
    disliked BOOLEAN NOT NULL DEFAULT FALSE
);

-- MARK: FUNCTIONS
-- ███████╗██╗░░░██╗███╗░░██╗░█████╗░████████╗██╗░█████╗░███╗░░██╗░██████╗
-- ██╔════╝██║░░░██║████╗░██║██╔══██╗╚══██╔══╝██║██╔══██╗████╗░██║██╔════╝
-- █████╗░░██║░░░██║██╔██╗██║██║░░╚═╝░░░██║░░░██║██║░░██║██╔██╗██║╚█████╗░
-- ██╔══╝░░██║░░░██║██║╚████║██║░░██╗░░░██║░░░██║██║░░██║██║╚████║░╚═══██╗
-- ██║░░░░░╚██████╔╝██║░╚███║╚█████╔╝░░░██║░░░██║╚█████╔╝██║░╚███║██████╔╝
-- ╚═╝░░░░░░╚═════╝░╚═╝░░╚══╝░╚════╝░░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝╚═════╝░



CREATE FUNCTION GetAllPokemon()
RETURNS TABLE (
    id INT,
    name VARCHAR(100),
    type1 Type,
    type2 Type,
    height DOUBLE PRECISION,
    weight DOUBLE PRECISION,
    liked BOOLEAN,
    disliked BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY SELECT * FROM Pokemon;
END;
$$;

CREATE FUNCTION GetPokemonById(
    IN p_id INT
)
RETURNS TABLE (
    id INT,
    name VARCHAR(100),
    type1 Type,
    type2 Type,
    height DOUBLE PRECISION,
    weight DOUBLE PRECISION,
    liked BOOLEAN,
    disliked BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY SELECT * FROM Pokemon WHERE id = p_id;
END;
$$;

CREATE FUNCTION GetAllLikedPokemon()
RETURNS TABLE (
    id INT,
    name VARCHAR(100),
    type1 Type,
    type2 Type,
    height DOUBLE PRECISION,
    weight DOUBLE PRECISION,
    liked BOOLEAN,
    disliked BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY SELECT * FROM Pokemon WHERE liked = TRUE;
END;
$$;

CREATE FUNCTION InsertPokemon(
    IN p_id INT,
    IN p_name VARCHAR(100),
    IN p_type1 Type,
    IN p_type2 Type,
    IN p_height DOUBLE PRECISION,
    IN p_weight DOUBLE PRECISION
)
RETURNS TABLE (
    id INT,
    name VARCHAR(100),
    type1 Type,
    type2 Type,
    height DOUBLE PRECISION,
    weight DOUBLE PRECISION,
    liked BOOLEAN,
    disliked BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Pokemon (id, name, type1, type2, height, weight)
    VALUES (p_id, p_name, p_type1, p_type2, p_height, p_weight)
    RETURNING *;
END;
$$;

-- MARK: PROCEDURES
-- ██████╗░██████╗░░█████╗░░█████╗░███████╗██████╗░██╗░░░██╗██████╗░███████╗░██████╗
-- ██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗██║░░░██║██╔══██╗██╔════╝██╔════╝
-- ██████╔╝██████╔╝██║░░██║██║░░╚═╝█████╗░░██║░░██║██║░░░██║██████╔╝█████╗░░╚█████╗░
-- ██╔═══╝░██╔══██╗██║░░██║██║░░██╗██╔══╝░░██║░░██║██║░░░██║██╔══██╗██╔══╝░░░╚═══██╗
-- ██║░░░░░██║░░██║╚█████╔╝╚█████╔╝███████╗██████╔╝╚██████╔╝██║░░██║███████╗██████╔╝
-- ╚═╝░░░░░╚═╝░░╚═╝░╚════╝░░╚════╝░╚══════╝╚═════╝░░╚═════╝░╚═╝░░╚═╝╚══════╝╚═════╝░

CREATE PROCEDURE likePokemon(
    IN p_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Pokemon
    SET liked = TRUE, disliked = FALSE
    WHERE id = p_id;
END;
$$;

CREATE PROCEDURE dislikePokemon(
    IN p_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Pokemon
    SET liked = FALSE, disliked = TRUE
    WHERE id = p_id;
END;
$$;