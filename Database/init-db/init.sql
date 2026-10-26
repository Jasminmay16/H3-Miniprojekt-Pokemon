-- MARK: TYPES
-- ████████╗██╗░░░██╗██████╗░███████╗░██████╗
-- ╚══██╔══╝╚██╗░██╔╝██╔══██╗██╔════╝██╔════╝
-- ░░░██║░░░░╚████╔╝░██████╔╝█████╗░░╚█████╗░
-- ░░░██║░░░░░╚██╔╝░░██╔═══╝░██╔══╝░░░╚═══██╗
-- ░░░██║░░░░░░██║░░░██║░░░░░███████╗██████╔╝
-- ░░░╚═╝░░░░░░╚═╝░░░╚═╝░░░░░╚══════╝╚═════╝░

-- tables are dropped first so they never hold a reference to a stale enum
DROP TABLE IF EXISTS Log;
DROP TABLE IF EXISTS Pokemon;

-- The enum is created only when missing. PostgreSQL has no CREATE OR REPLACE
-- TYPE, and dropping/recreating it assigns a new OID. Clients such as Npgsql
-- cache that OID for the lifetime of the process, so a running backend would
-- keep reading rows tagged with an OID it has never seen and fail with
-- "DataTypeName '-'" until restarted. Adding a value later therefore needs an
-- explicit ALTER TYPE Type ADD VALUE '...'.
DO $$
BEGIN
    IF to_regtype('type') IS NULL THEN
        CREATE TYPE Type AS ENUM (
            'normal',
            'fire',
            'water',
            'grass',
            'electric',
            'ice',
            'fighting',
            'poison',
            'ground',
            'flying',
            'psychic',
            'bug',
            'rock',
            'ghost',
            'dragon',
            'dark',
            'steel',
            'fairy'
        );
    END IF;
END
$$;

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

CREATE TABLE IF NOT EXISTS Log (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    action VARCHAR(500) NOT NULL,
    pokemon_id INT REFERENCES Pokemon(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- MARK: FUNCTIONS
-- ███████╗██╗░░░██╗███╗░░██╗░█████╗░████████╗██╗░█████╗░███╗░░██╗░██████╗
-- ██╔════╝██║░░░██║████╗░██║██╔══██╗╚══██╔══╝██║██╔══██╗████╗░██║██╔════╝
-- █████╗░░██║░░░██║██╔██╗██║██║░░╚═╝░░░██║░░░██║██║░░██║██╔██╗██║╚█████╗░
-- ██╔══╝░░██║░░░██║██║╚████║██║░░██╗░░░██║░░░██║██║░░██║██║╚████║░╚═══██╗
-- ██║░░░░░╚██████╔╝██║░╚███║╚█████╔╝░░░██║░░░██║╚█████╔╝██║░╚███║██████╔╝
-- ╚═╝░░░░░░╚═════╝░╚═╝░░╚══╝░╚════╝░░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝╚═════╝░


-- SELECT * FROM GetAllPokemon();
CREATE OR REPLACE FUNCTION GetAllPokemon()
RETURNS TABLE (
    id INT,
    name VARCHAR(100),
    type1 TEXT,
    type2 TEXT,
    height DOUBLE PRECISION,
    weight DOUBLE PRECISION,
    liked BOOLEAN,
    disliked BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Log(action, pokemon_id) VALUES ('GetAllPokemon() called', NULL);
    RETURN QUERY SELECT p.id, p.name, p.type1::TEXT, p.type2::TEXT,
                        p.height, p.weight, p.liked, p.disliked
                 FROM Pokemon AS p;
END;
$$;

-- SELECT * FROM GetPokemonById(id);
CREATE OR REPLACE FUNCTION GetPokemonById(
    p_id INT
)
RETURNS TABLE (
    id INT,
    name VARCHAR(100),
    type1 TEXT,
    type2 TEXT,
    height DOUBLE PRECISION,
    weight DOUBLE PRECISION,
    liked BOOLEAN,
    disliked BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- NULL when the id is unknown, otherwise the FK would reject the log row
    INSERT INTO Log(action, pokemon_id) VALUES ('GetPokemonById(' || p_id || ') called', (SELECT p.id FROM Pokemon AS p WHERE p.id = p_id));
    RETURN QUERY SELECT p.* FROM GetAllPokemon() AS p WHERE p.id = p_id;
END;
$$;

-- SELECT * FROM GetAllPokemonWithNoLikesOrDislikes();
CREATE OR REPLACE FUNCTION GetAllPokemonWithNoLikesOrDislikes()
RETURNS TABLE (
    id INT,
    name VARCHAR(100),
    type1 TEXT,
    type2 TEXT,
    height DOUBLE PRECISION,
    weight DOUBLE PRECISION,
    liked BOOLEAN,
    disliked BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE
    selected_pokemon RECORD;
BEGIN
    -- Log the function call
    INSERT INTO Log(action, pokemon_id) VALUES ('GetAllPokemonWithNoLikesOrDislikes() called', NULL);

    -- Select a random Pokémon with no likes or dislikes
    SELECT * INTO selected_pokemon
    FROM GetAllPokemon() AS p
    WHERE p.liked = FALSE AND p.disliked = FALSE
    ORDER BY RANDOM()
    LIMIT 1;

    -- If a Pokémon is found, log it and return it
    IF selected_pokemon IS NOT NULL THEN
        INSERT INTO Log(action, pokemon_id) 
        VALUES ('Random Pokémon selected: ' || selected_pokemon.name, selected_pokemon.id);
        RETURN NEXT selected_pokemon;
    END IF;

    -- If no Pokémon is found, return nothing
    RETURN;
END;
$$;

-- SELECT * FROM GetAllLikedPokemon();
CREATE OR REPLACE FUNCTION GetAllLikedPokemon()
RETURNS TABLE (
    id INT,
    name VARCHAR(100),
    type1 TEXT,
    type2 TEXT,
    height DOUBLE PRECISION,
    weight DOUBLE PRECISION,
    liked BOOLEAN,
    disliked BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Log(action, pokemon_id) VALUES ('GetAllLikedPokemon() called', NULL);
    RETURN QUERY SELECT p.* FROM GetAllPokemon() AS p WHERE p.liked = TRUE;
END;
$$;


-- SELECT * FROM GetAllDislikedPokemon();
CREATE OR REPLACE FUNCTION GetAllDislikedPokemon()
RETURNS TABLE (
    id INT,
    name VARCHAR(100),
    type1 TEXT,
    type2 TEXT,
    height DOUBLE PRECISION,
    weight DOUBLE PRECISION,
    liked BOOLEAN,
    disliked BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Log(action, pokemon_id) VALUES ('GetAllDislikedPokemon() called', NULL);
    RETURN QUERY SELECT p.* FROM GetAllPokemon() AS p WHERE p.disliked = TRUE;
END;
$$;


-- SELECT * FROM GetLogEntries();
CREATE OR REPLACE FUNCTION GetLogEntries()
RETURNS TABLE (
    id INT,
    action VARCHAR(500),
    pokemon_id INT,
    pokemon_name VARCHAR(100),
    created_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY SELECT l.id, l.action, l.pokemon_id, p.name AS pokemon_name, l.created_at
                 FROM Log AS l
                 LEFT JOIN Pokemon AS p ON l.pokemon_id = p.id
                 ORDER BY l.created_at DESC, l.id DESC
                 LIMIT 100;
END;
$$;


-- MARK: PROCEDURES
-- ██████╗░██████╗░░█████╗░░█████╗░███████╗██████╗░██╗░░░██╗██████╗░███████╗░██████╗
-- ██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗██║░░░██║██╔══██╗██╔════╝██╔════╝
-- ██████╔╝██████╔╝██║░░██║██║░░╚═╝█████╗░░██║░░██║██║░░░██║██████╔╝█████╗░░╚█████╗░
-- ██╔═══╝░██╔══██╗██║░░██║██║░░██╗██╔══╝░░██║░░██║██║░░░██║██╔══██╗██╔══╝░░░╚═══██╗
-- ██║░░░░░██║░░██║╚█████╔╝╚█████╔╝███████╗██████╔╝╚██████╔╝██║░░██║███████╗██████╔╝
-- ╚═╝░░░░░╚═╝░░╚═╝░╚════╝░░╚════╝░╚══════╝╚═════╝░░╚═════╝░╚═╝░░╚═╝╚══════╝╚═════╝░


-- CALL InsertPokemon(id, name, type1, type2, height, weight);
CREATE OR REPLACE PROCEDURE InsertPokemon(
    IN p_id INT,
    IN p_name TEXT,
    IN p_type1 TEXT,
    IN p_type2 TEXT,
    IN p_height DOUBLE PRECISION,
    IN p_weight DOUBLE PRECISION
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM GetPokemonById(p_id)) THEN
        INSERT INTO Pokemon (id, name, type1, type2, height, weight)
        VALUES (p_id, p_name, p_type1::Type, p_type2::Type, p_height, p_weight);
    ELSE
        UPDATE Pokemon
        SET name = p_name,
            type1 = p_type1::Type,
            type2 = p_type2::Type,
            height = p_height,
            weight = p_weight
        WHERE id = p_id;
    END IF;
    -- logged after the upsert so the FK on pokemon_id resolves
    INSERT INTO Log(action, pokemon_id) VALUES ('InsertPokemon(' || p_id || ', ' || p_name || ', ' || p_type1 || ', ' || COALESCE(p_type2, 'NULL') || ', ' || p_height || ', ' || p_weight || ') called', p_id);
END;
$$;


-- CALL LikePokemon(id);
CREATE OR REPLACE PROCEDURE LikePokemon(
    IN p_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Log(action, pokemon_id) VALUES ('LikePokemon(' || p_id || ') called', (SELECT p.id FROM Pokemon AS p WHERE p.id = p_id));
    UPDATE Pokemon
    SET liked = TRUE, disliked = FALSE
    WHERE id = p_id;
END;
$$;


-- CALL DislikePokemon(id);
CREATE OR REPLACE PROCEDURE DislikePokemon(
    IN p_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Log(action, pokemon_id) VALUES ('DislikePokemon(' || p_id || ') called', (SELECT p.id FROM Pokemon AS p WHERE p.id = p_id));
    UPDATE Pokemon
    SET liked = FALSE, disliked = TRUE
    WHERE id = p_id;
END;
$$;

-- MARK: DATA INSERT
-- ██████╗░░█████╗░████████╗░█████╗░  ██╗███╗░░██╗░██████╗███████╗██████╗░████████╗
-- ██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗  ██║████╗░██║██╔════╝██╔════╝██╔══██╗╚══██╔══╝
-- ██║░░██║███████║░░░██║░░░███████║  ██║██╔██╗██║╚█████╗░█████╗░░██████╔╝░░░██║░░░
-- ██║░░██║██╔══██║░░░██║░░░██╔══██║  ██║██║╚████║░╚═══██╗██╔══╝░░██╔══██╗░░░██║░░░
-- ██████╔╝██║░░██║░░░██║░░░██║░░██║  ██║██║░╚███║██████╔╝███████╗██║░░██║░░░██║░░░
-- ╚═════╝░╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░╚═╝  ╚═╝╚═╝░░╚══╝╚═════╝░╚══════╝╚═╝░░╚═╝░░░╚═╝░░░



CALL InsertPokemon(1, 'Bulbasaur', 'grass', 'poison', 0.7, 6.9);
CALL InsertPokemon(2, 'Ivysaur', 'grass', 'poison', 1.0, 13.0);
CALL InsertPokemon(3, 'Venusaur', 'grass', 'poison', 2.0, 100.0);
CALL InsertPokemon(4, 'Charmander', 'fire', NULL, 0.6, 8.5);
CALL InsertPokemon(5, 'Charmeleon', 'fire', NULL, 1.1, 19.0);
CALL InsertPokemon(6, 'Charizard', 'fire', 'flying', 1.7, 90.5);
CALL InsertPokemon(7, 'Squirtle', 'water', NULL, 0.5, 9.0);
CALL InsertPokemon(8, 'Wartortle', 'water', NULL, 1.0, 22.5);
CALL InsertPokemon(9, 'Blastoise', 'water', NULL, 1.6, 85.5);
CALL InsertPokemon(10, 'Caterpie', 'bug', NULL, 0.3, 2.9);
CALL InsertPokemon(11, 'Metapod', 'bug', NULL, 0.7, 9.9);
CALL InsertPokemon(12, 'Butterfree', 'bug', 'flying', 1.1, 32.0);
CALL InsertPokemon(13, 'Weedle', 'bug', 'poison', 0.3, 3.2);
CALL InsertPokemon(14, 'Kakuna', 'bug', 'poison', 0.6, 10.0);
CALL InsertPokemon(15, 'Beedrill', 'bug', 'poison', 1.0, 29.5);
CALL InsertPokemon(16, 'Pidgey', 'normal', 'flying', 0.3, 1.8);
CALL InsertPokemon(17, 'Pidgeotto', 'normal', 'flying', 1.1, 30.0);
CALL InsertPokemon(18, 'Pidgeot', 'normal', 'flying', 1.5, 39.5);
CALL InsertPokemon(19, 'Rattata', 'normal', NULL, 0.3, 3.5);
CALL InsertPokemon(20, 'Raticate', 'normal', NULL, 0.7, 18.5);
CALL InsertPokemon(21, 'Spearow', 'normal', 'flying', 0.3, 2.0);
CALL InsertPokemon(22, 'Fearow', 'normal', 'flying', 1.2, 38.0);
CALL InsertPokemon(23, 'Ekans', 'poison', NULL, 2.0, 6.9);
CALL InsertPokemon(24, 'Arbok', 'poison', NULL, 3.5, 65.0);
CALL InsertPokemon(25, 'Pikachu', 'electric', NULL, 0.4, 6.0);
CALL InsertPokemon(26, 'Raichu', 'electric', NULL, 0.8, 30.0);
CALL InsertPokemon(27, 'Sandshrew', 'ground', NULL, 0.6, 12.0);
CALL InsertPokemon(28, 'Sandslash', 'ground', NULL, 1.0, 29.5);
CALL InsertPokemon(29, 'Nidoran♀', 'poison', NULL, 0.4, 7.0);
CALL InsertPokemon(30, 'Nidorina', 'poison', NULL, 0.8, 20.0);
CALL InsertPokemon(31, 'Nidoqueen', 'poison', 'ground', 1.3, 60.0);
CALL InsertPokemon(32, 'Nidoran♂', 'poison', NULL, 0.5, 9.0);
CALL InsertPokemon(33, 'Nidorino', 'poison', NULL, 0.9, 19.5);
CALL InsertPokemon(34, 'Nidoking', 'poison', 'ground', 1.4, 62.0);
CALL InsertPokemon(35, 'Clefairy', 'fairy', NULL, 0.6, 7.5);
CALL InsertPokemon(36, 'Clefable', 'fairy', NULL, 1.3, 40.0);
CALL InsertPokemon(37, 'Vulpix', 'fire', NULL, 0.6, 9.9);
CALL InsertPokemon(38, 'Ninetales', 'fire', NULL, 1.1, 19.9);
CALL InsertPokemon(39, 'Jigglypuff', 'normal', 'fairy', 0.5, 5.5);
CALL InsertPokemon(40, 'Wigglytuff', 'normal', 'fairy', 1.0, 12.0);
CALL InsertPokemon(41, 'Zubat', 'poison', 'flying', 0.8, 7.5);
CALL InsertPokemon(42, 'Golbat', 'poison', 'flying', 1.6, 55.0);
CALL InsertPokemon(43, 'Oddish', 'grass', 'poison', 0.5, 5.4);
CALL InsertPokemon(44, 'Gloom', 'grass', 'poison', 0.8, 8.6);
CALL InsertPokemon(45, 'Vileplume', 'grass', 'poison', 1.2, 18.6);
CALL InsertPokemon(46, 'Paras', 'bug', 'grass', 0.3, 5.4);
CALL InsertPokemon(47, 'Parasect', 'bug', 'grass', 1.0, 29.5);
CALL InsertPokemon(48, 'Venonat', 'bug', 'poison', 1.0, 30.0);
CALL InsertPokemon(49, 'Venomoth', 'bug', 'poison', 1.5, 12.5);
CALL InsertPokemon(50, 'Diglett', 'ground', NULL, 0.2, 0.8);
CALL InsertPokemon(51, 'Dugtrio', 'ground', NULL, 0.7, 33.3);
CALL InsertPokemon(52, 'Meowth', 'normal', NULL, 0.4, 4.2);
CALL InsertPokemon(53, 'Persian', 'normal', NULL, 1.0, 32.0);
CALL InsertPokemon(54, 'Psyduck', 'water', NULL, 0.8, 19.6);
CALL InsertPokemon(55, 'Golduck', 'water', NULL, 1.7, 76.6);
CALL InsertPokemon(56, 'Mankey', 'fighting', NULL, 0.5, 28.0);
CALL InsertPokemon(57, 'Primeape', 'fighting', NULL, 1.0, 32.0);
CALL InsertPokemon(58, 'Growlithe', 'fire', NULL, 0.7, 19.0);
CALL InsertPokemon(59, 'Arcanine', 'fire', NULL, 1.9, 155.0);
CALL InsertPokemon(60, 'Poliwag', 'water', NULL, 0.6, 12.4);
CALL InsertPokemon(61, 'Poliwhirl', 'water', NULL, 1.0, 20.0);
CALL InsertPokemon(62, 'Poliwrath', 'water', 'fighting', 1.3, 54.0);
CALL InsertPokemon(63, 'Abra', 'psychic', NULL, 0.9, 19.5);
CALL InsertPokemon(64, 'Kadabra', 'psychic', NULL, 1.3, 56.5);
CALL InsertPokemon(65, 'Alakazam', 'psychic', NULL, 1.5, 48.0);
CALL InsertPokemon(66, 'Machop', 'fighting', NULL, 0.8, 19.5);
CALL InsertPokemon(67, 'Machoke', 'fighting', NULL, 1.5, 70.5);
CALL InsertPokemon(68, 'Machamp', 'fighting', NULL, 1.6, 130.0);
CALL InsertPokemon(69, 'Bellsprout', 'grass', 'poison', 0.7, 4.0);
CALL InsertPokemon(70, 'Weepinbell', 'grass', 'poison', 1.0, 6.4);
CALL InsertPokemon(71, 'Victreebel', 'grass', 'poison', 1.7, 15.5);
CALL InsertPokemon(72, 'Tentacool', 'water', 'poison', 0.9, 45.5);
CALL InsertPokemon(73, 'Tentacruel', 'water', 'poison', 1.6, 55.0);
CALL InsertPokemon(74, 'Geodude', 'rock', 'ground', 0.4, 20.0);
CALL InsertPokemon(75, 'Graveler', 'rock', 'ground', 1.0, 105.0);
CALL InsertPokemon(76, 'Golem', 'rock', 'ground', 1.4, 300.0);
CALL InsertPokemon(77, 'Ponyta', 'fire', NULL, 1.0, 30.0);
CALL InsertPokemon(78, 'Rapidash', 'fire', NULL, 1.7, 95.0);
CALL InsertPokemon(79, 'Slowpoke', 'water', 'psychic', 1.2, 36.0);
CALL InsertPokemon(80, 'Slowbro', 'water', 'psychic', 1.6, 78.5);
CALL InsertPokemon(81, 'Magnemite', 'electric', 'steel', 0.3, 6.0);
CALL InsertPokemon(82, 'Magneton', 'electric', 'steel', 1.0, 60.0);
CALL InsertPokemon(83, 'Farfetch''d', 'normal', 'flying', 0.8, 15.0);
CALL InsertPokemon(84, 'Doduo', 'normal', 'flying', 1.4, 39.2);
CALL InsertPokemon(85, 'Dodrio', 'normal', 'flying', 1.8, 85.2);
CALL InsertPokemon(86, 'Seel', 'water', NULL, 1.1, 90.0);
CALL InsertPokemon(87, 'Dewgong', 'water', 'ice', 1.7, 120.0);
CALL InsertPokemon(88, 'Grimer', 'poison', NULL, 0.9, 30.0);
CALL InsertPokemon(89, 'Muk', 'poison', NULL, 1.2, 30.0);
CALL InsertPokemon(90, 'Shellder', 'water', NULL, 0.3, 4.0);
CALL InsertPokemon(91, 'Cloyster', 'water', 'ice', 1.5, 132.5);
CALL InsertPokemon(92, 'Gastly', 'ghost', 'poison', 1.3, 0.1);
CALL InsertPokemon(93, 'Haunter', 'ghost', 'poison', 1.6, 0.1);
CALL InsertPokemon(94, 'Gengar', 'ghost', 'poison', 1.5, 40.5);
CALL InsertPokemon(95, 'Onix', 'rock', 'ground', 8.8, 210.0);
CALL InsertPokemon(96, 'Drowzee', 'psychic', NULL, 1.0, 32.4);
CALL InsertPokemon(97, 'Hypno', 'psychic', NULL, 1.6, 75.6);
CALL InsertPokemon(98, 'Krabby', 'water', NULL, 0.4, 6.5);
CALL InsertPokemon(99, 'Kingler', 'water', NULL, 1.3, 60.0);
CALL InsertPokemon(100, 'Voltorb', 'electric', NULL, 0.5, 10.4);
CALL InsertPokemon(101, 'Electrode', 'electric', NULL, 1.2, 66.6);
CALL InsertPokemon(102, 'Exeggcute', 'grass', 'psychic', 0.4, 2.5);
CALL InsertPokemon(103, 'Exeggutor', 'grass', 'psychic', 2.0, 120.0);
CALL InsertPokemon(104, 'Cubone', 'ground', NULL, 0.4, 6.5);
CALL InsertPokemon(105, 'Marowak', 'ground', NULL, 1.0, 45.0);
CALL InsertPokemon(106, 'Hitmonlee', 'fighting', NULL, 1.5, 49.8);
CALL InsertPokemon(107, 'Hitmonchan', 'fighting', NULL, 1.4, 50.2);
CALL InsertPokemon(108, 'Lickitung', 'normal', NULL, 1.2, 65.5);
CALL InsertPokemon(109, 'Koffing', 'poison', NULL, 0.6, 9.5);
CALL InsertPokemon(110, 'Weezing', 'poison', NULL, 1.2, 9.5);
CALL InsertPokemon(111, 'Rhyhorn', 'ground', 'rock', 1.0, 115.0);
CALL InsertPokemon(112, 'Rhydon', 'ground', 'rock', 1.9, 120.0);
CALL InsertPokemon(113, 'Chansey', 'normal', NULL, 1.1, 34.6);
CALL InsertPokemon(114, 'Tangela', 'grass', NULL, 1.0, 35.0);
CALL InsertPokemon(115, 'Kangaskhan', 'normal', NULL, 2.2, 80.0);
CALL InsertPokemon(116, 'Horsea', 'water', NULL, 0.4, 8.0);
CALL InsertPokemon(117, 'Seadra', 'water', NULL, 1.8, 25.0);
CALL InsertPokemon(118, 'Goldeen', 'water', NULL, 0.6, 15.0);
CALL InsertPokemon(119, 'Seaking', 'water', NULL, 1.3, 39.0);
CALL InsertPokemon(120, 'Staryu', 'water', NULL, 0.8, 34.5);
CALL InsertPokemon(121, 'Starmie', 'water', 'psychic', 1.1, 80.0);
CALL InsertPokemon(122, 'Mr. Mime', 'psychic', 'fairy', 1.3, 54.5);
CALL InsertPokemon(123, 'Scyther', 'bug', 'flying', 1.5, 56.0);
CALL InsertPokemon(124, 'Jynx', 'ice', 'psychic', 1.4, 40.6);
CALL InsertPokemon(125, 'Electabuzz', 'electric', NULL, 1.1, 30.0);
CALL InsertPokemon(126, 'Magmar', 'fire', NULL, 1.3, 44.5);
CALL InsertPokemon(127, 'Pinsir', 'bug', NULL, 1.5, 55.0);
CALL InsertPokemon(128, 'Tauros', 'normal', NULL, 1.4, 88.4);
CALL InsertPokemon(129, 'Magikarp', 'water', NULL, 0.9, 10.0);
CALL InsertPokemon(130, 'Gyarados', 'water', 'flying', 6.5, 235.0);
CALL InsertPokemon(131, 'Lapras', 'water', 'ice', 2.5, 220.0);
CALL InsertPokemon(132, 'Ditto', 'normal', NULL, 0.3, 4.0);
CALL InsertPokemon(133, 'Eevee', 'normal', NULL, 0.3, 6.5);
CALL InsertPokemon(134, 'Vaporeon', 'water', NULL, 1.0, 29.0);
CALL InsertPokemon(135, 'Jolteon', 'electric', NULL, 0.8, 24.5);
CALL InsertPokemon(136, 'Flareon', 'fire', NULL, 0.9, 25.0);
CALL InsertPokemon(137, 'Porygon', 'normal', NULL, 0.8, 36.5);
CALL InsertPokemon(138, 'Omanyte', 'rock', 'water', 0.4, 7.5);
CALL InsertPokemon(139, 'Omastar', 'rock', 'water', 1.0, 35.0);
CALL InsertPokemon(140, 'Kabuto', 'rock', 'water', 0.5, 11.5);
CALL InsertPokemon(141, 'Kabutops', 'rock', 'water', 1.3, 40.5);
CALL InsertPokemon(142, 'Aerodactyl', 'rock', 'flying', 1.8, 59.0);
CALL InsertPokemon(143, 'Snorlax', 'normal', NULL, 2.1, 460.0);
CALL InsertPokemon(144, 'Articuno', 'ice', 'flying', 1.7, 55.4);
CALL InsertPokemon(145, 'Zapdos', 'electric', 'flying', 1.6, 52.6);
CALL InsertPokemon(146, 'Moltres', 'fire', 'flying', 2.0, 60.0);
CALL InsertPokemon(147, 'Dratini', 'dragon', NULL, 1.8, 3.3);
CALL InsertPokemon(148, 'dragonair', 'dragon', NULL, 4.0, 16.5);
CALL InsertPokemon(149, 'dragonite', 'dragon', 'flying', 2.2, 210.0);
CALL InsertPokemon(150, 'Mewtwo', 'psychic', NULL, 2.0, 122.0);
CALL InsertPokemon(151, 'Mew', 'psychic', NULL, 0.4, 4.0);