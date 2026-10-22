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


-- SELECT * FROM GetAllPokemon();
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

-- SELECT * FROM GetPokemonById(id);
CREATE FUNCTION GetPokemonById(
    p_id INT
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
    RETURN QUERY SELECT p.* FROM GetAllPokemon() AS p WHERE p.id = p_id;
END;
$$;


-- SELECT * FROM GetAllLikedPokemon();
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
    RETURN QUERY SELECT p.* FROM GetAllPokemon() AS p WHERE p.liked = TRUE;
END;
$$;


-- SELECT * FROM GetAllDislikedPokemon();
CREATE FUNCTION GetAllDislikedPokemon()
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
    RETURN QUERY SELECT p.* FROM GetAllPokemon() AS p WHERE p.disliked = TRUE;
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
CREATE PROCEDURE InsertPokemon(
    IN p_id INT,
    IN p_name VARCHAR(100),
    IN p_type1 Type,
    IN p_type2 Type,
    IN p_height DOUBLE PRECISION,
    IN p_weight DOUBLE PRECISION
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Pokemon (id, name, type1, type2, height, weight)
    VALUES (p_id, p_name, p_type1, p_type2, p_height, p_weight);
END;
$$;


-- CALL LikePokemon(id);
CREATE PROCEDURE LikePokemon(
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


-- CALL DislikePokemon(id);
CREATE PROCEDURE DislikePokemon(
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

-- MARK: DATA INSERT
-- ██████╗░░█████╗░████████╗░█████╗░  ██╗███╗░░██╗░██████╗███████╗██████╗░████████╗
-- ██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗  ██║████╗░██║██╔════╝██╔════╝██╔══██╗╚══██╔══╝
-- ██║░░██║███████║░░░██║░░░███████║  ██║██╔██╗██║╚█████╗░█████╗░░██████╔╝░░░██║░░░
-- ██║░░██║██╔══██║░░░██║░░░██╔══██║  ██║██║╚████║░╚═══██╗██╔══╝░░██╔══██╗░░░██║░░░
-- ██████╔╝██║░░██║░░░██║░░░██║░░██║  ██║██║░╚███║██████╔╝███████╗██║░░██║░░░██║░░░
-- ╚═════╝░╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░╚═╝  ╚═╝╚═╝░░╚══╝╚═════╝░╚══════╝╚═╝░░╚═╝░░░╚═╝░░░



CALL InsertPokemon(1, 'Bulbasaur', 'Grass', 'Poison', 0.7, 6.9);
CALL InsertPokemon(2, 'Ivysaur', 'Grass', 'Poison', 1.0, 13.0);
CALL InsertPokemon(3, 'Venusaur', 'Grass', 'Poison', 2.0, 100.0);
CALL InsertPokemon(4, 'Charmander', 'Fire', NULL, 0.6, 8.5);
CALL InsertPokemon(5, 'Charmeleon', 'Fire', NULL, 1.1, 19.0);
CALL InsertPokemon(6, 'Charizard', 'Fire', 'Flying', 1.7, 90.5);
CALL InsertPokemon(7, 'Squirtle', 'Water', NULL, 0.5, 9.0);
CALL InsertPokemon(8, 'Wartortle', 'Water', NULL, 1.0, 22.5);
CALL InsertPokemon(9, 'Blastoise', 'Water', NULL, 1.6, 85.5);
CALL InsertPokemon(10, 'Caterpie', 'Bug', NULL, 0.3, 2.9);
CALL InsertPokemon(11, 'Metapod', 'Bug', NULL, 0.7, 9.9);
CALL InsertPokemon(12, 'Butterfree', 'Bug', 'Flying', 1.1, 32.0);
CALL InsertPokemon(13, 'Weedle', 'Bug', 'Poison', 0.3, 3.2);
CALL InsertPokemon(14, 'Kakuna', 'Bug', 'Poison', 0.6, 10.0);
CALL InsertPokemon(15, 'Beedrill', 'Bug', 'Poison', 1.0, 29.5);
CALL InsertPokemon(16, 'Pidgey', 'Normal', 'Flying', 0.3, 1.8);
CALL InsertPokemon(17, 'Pidgeotto', 'Normal', 'Flying', 1.1, 30.0);
CALL InsertPokemon(18, 'Pidgeot', 'Normal', 'Flying', 1.5, 39.5);
CALL InsertPokemon(19, 'Rattata', 'Normal', NULL, 0.3, 3.5);
CALL InsertPokemon(20, 'Raticate', 'Normal', NULL, 0.7, 18.5);
CALL InsertPokemon(21, 'Spearow', 'Normal', 'Flying', 0.3, 2.0);
CALL InsertPokemon(22, 'Fearow', 'Normal', 'Flying', 1.2, 38.0);
CALL InsertPokemon(23, 'Ekans', 'Poison', NULL, 2.0, 6.9);
CALL InsertPokemon(24, 'Arbok', 'Poison', NULL, 3.5, 65.0);
CALL InsertPokemon(25, 'Pikachu', 'Electric', NULL, 0.4, 6.0);
CALL InsertPokemon(26, 'Raichu', 'Electric', NULL, 0.8, 30.0);
CALL InsertPokemon(27, 'Sandshrew', 'Ground', NULL, 0.6, 12.0);
CALL InsertPokemon(28, 'Sandslash', 'Ground', NULL, 1.0, 29.5);
CALL InsertPokemon(29, 'Nidoran♀', 'Poison', NULL, 0.4, 7.0);
CALL InsertPokemon(30, 'Nidorina', 'Poison', NULL, 0.8, 20.0);
CALL InsertPokemon(31, 'Nidoqueen', 'Poison', 'Ground', 1.3, 60.0);
CALL InsertPokemon(32, 'Nidoran♂', 'Poison', NULL, 0.5, 9.0);
CALL InsertPokemon(33, 'Nidorino', 'Poison', NULL, 0.9, 19.5);
CALL InsertPokemon(34, 'Nidoking', 'Poison', 'Ground', 1.4, 62.0);
CALL InsertPokemon(35, 'Clefairy', 'Fairy', NULL, 0.6, 7.5);
CALL InsertPokemon(36, 'Clefable', 'Fairy', NULL, 1.3, 40.0);
CALL InsertPokemon(37, 'Vulpix', 'Fire', NULL, 0.6, 9.9);
CALL InsertPokemon(38, 'Ninetales', 'Fire', NULL, 1.1, 19.9);
CALL InsertPokemon(39, 'Jigglypuff', 'Normal', 'Fairy', 0.5, 5.5);
CALL InsertPokemon(40, 'Wigglytuff', 'Normal', 'Fairy', 1.0, 12.0);
CALL InsertPokemon(41, 'Zubat', 'Poison', 'Flying', 0.8, 7.5);
CALL InsertPokemon(42, 'Golbat', 'Poison', 'Flying', 1.6, 55.0);
CALL InsertPokemon(43, 'Oddish', 'Grass', 'Poison', 0.5, 5.4);
CALL InsertPokemon(44, 'Gloom', 'Grass', 'Poison', 0.8, 8.6);
CALL InsertPokemon(45, 'Vileplume', 'Grass', 'Poison', 1.2, 18.6);
CALL InsertPokemon(46, 'Paras', 'Bug', 'Grass', 0.3, 5.4);
CALL InsertPokemon(47, 'Parasect', 'Bug', 'Grass', 1.0, 29.5);
CALL InsertPokemon(48, 'Venonat', 'Bug', 'Poison', 1.0, 30.0);
CALL InsertPokemon(49, 'Venomoth', 'Bug', 'Poison', 1.5, 12.5);
CALL InsertPokemon(50, 'Diglett', 'Ground', NULL, 0.2, 0.8);
CALL InsertPokemon(51, 'Dugtrio', 'Ground', NULL, 0.7, 33.3);
CALL InsertPokemon(52, 'Meowth', 'Normal', NULL, 0.4, 4.2);
CALL InsertPokemon(53, 'Persian', 'Normal', NULL, 1.0, 32.0);
CALL InsertPokemon(54, 'Psyduck', 'Water', NULL, 0.8, 19.6);
CALL InsertPokemon(55, 'Golduck', 'Water', NULL, 1.7, 76.6);
CALL InsertPokemon(56, 'Mankey', 'Fighting', NULL, 0.5, 28.0);
CALL InsertPokemon(57, 'Primeape', 'Fighting', NULL, 1.0, 32.0);
CALL InsertPokemon(58, 'Growlithe', 'Fire', NULL, 0.7, 19.0);
CALL InsertPokemon(59, 'Arcanine', 'Fire', NULL, 1.9, 155.0);
CALL InsertPokemon(60, 'Poliwag', 'Water', NULL, 0.6, 12.4);
CALL InsertPokemon(61, 'Poliwhirl', 'Water', NULL, 1.0, 20.0);
CALL InsertPokemon(62, 'Poliwrath', 'Water', 'Fighting', 1.3, 54.0);
CALL InsertPokemon(63, 'Abra', 'Psychic', NULL, 0.9, 19.5);
CALL InsertPokemon(64, 'Kadabra', 'Psychic', NULL, 1.3, 56.5);
CALL InsertPokemon(65, 'Alakazam', 'Psychic', NULL, 1.5, 48.0);
CALL InsertPokemon(66, 'Machop', 'Fighting', NULL, 0.8, 19.5);
CALL InsertPokemon(67, 'Machoke', 'Fighting', NULL, 1.5, 70.5);
CALL InsertPokemon(68, 'Machamp', 'Fighting', NULL, 1.6, 130.0);
CALL InsertPokemon(69, 'Bellsprout', 'Grass', 'Poison', 0.7, 4.0);
CALL InsertPokemon(70, 'Weepinbell', 'Grass', 'Poison', 1.0, 6.4);
CALL InsertPokemon(71, 'Victreebel', 'Grass', 'Poison', 1.7, 15.5);
CALL InsertPokemon(72, 'Tentacool', 'Water', 'Poison', 0.9, 45.5);
CALL InsertPokemon(73, 'Tentacruel', 'Water', 'Poison', 1.6, 55.0);
CALL InsertPokemon(74, 'Geodude', 'Rock', 'Ground', 0.4, 20.0);
CALL InsertPokemon(75, 'Graveler', 'Rock', 'Ground', 1.0, 105.0);
CALL InsertPokemon(76, 'Golem', 'Rock', 'Ground', 1.4, 300.0);
CALL InsertPokemon(77, 'Ponyta', 'Fire', NULL, 1.0, 30.0);
CALL InsertPokemon(78, 'Rapidash', 'Fire', NULL, 1.7, 95.0);
CALL InsertPokemon(79, 'Slowpoke', 'Water', 'Psychic', 1.2, 36.0);
CALL InsertPokemon(80, 'Slowbro', 'Water', 'Psychic', 1.6, 78.5);
CALL InsertPokemon(81, 'Magnemite', 'Electric', 'Steel', 0.3, 6.0);
CALL InsertPokemon(82, 'Magneton', 'Electric', 'Steel', 1.0, 60.0);
CALL InsertPokemon(83, 'Farfetch''d', 'Normal', 'Flying', 0.8, 15.0);
CALL InsertPokemon(84, 'Doduo', 'Normal', 'Flying', 1.4, 39.2);
CALL InsertPokemon(85, 'Dodrio', 'Normal', 'Flying', 1.8, 85.2);
CALL InsertPokemon(86, 'Seel', 'Water', NULL, 1.1, 90.0);
CALL InsertPokemon(87, 'Dewgong', 'Water', 'Ice', 1.7, 120.0);
CALL InsertPokemon(88, 'Grimer', 'Poison', NULL, 0.9, 30.0);
CALL InsertPokemon(89, 'Muk', 'Poison', NULL, 1.2, 30.0);
CALL InsertPokemon(90, 'Shellder', 'Water', NULL, 0.3, 4.0);
CALL InsertPokemon(91, 'Cloyster', 'Water', 'Ice', 1.5, 132.5);
CALL InsertPokemon(92, 'Gastly', 'Ghost', 'Poison', 1.3, 0.1);
CALL InsertPokemon(93, 'Haunter', 'Ghost', 'Poison', 1.6, 0.1);
CALL InsertPokemon(94, 'Gengar', 'Ghost', 'Poison', 1.5, 40.5);
CALL InsertPokemon(95, 'Onix', 'Rock', 'Ground', 8.8, 210.0);
CALL InsertPokemon(96, 'Drowzee', 'Psychic', NULL, 1.0, 32.4);
CALL InsertPokemon(97, 'Hypno', 'Psychic', NULL, 1.6, 75.6);
CALL InsertPokemon(98, 'Krabby', 'Water', NULL, 0.4, 6.5);
CALL InsertPokemon(99, 'Kingler', 'Water', NULL, 1.3, 60.0);
CALL InsertPokemon(100, 'Voltorb', 'Electric', NULL, 0.5, 10.4);
CALL InsertPokemon(101, 'Electrode', 'Electric', NULL, 1.2, 66.6);
CALL InsertPokemon(102, 'Exeggcute', 'Grass', 'Psychic', 0.4, 2.5);
CALL InsertPokemon(103, 'Exeggutor', 'Grass', 'Psychic', 2.0, 120.0);
CALL InsertPokemon(104, 'Cubone', 'Ground', NULL, 0.4, 6.5);
CALL InsertPokemon(105, 'Marowak', 'Ground', NULL, 1.0, 45.0);
CALL InsertPokemon(106, 'Hitmonlee', 'Fighting', NULL, 1.5, 49.8);
CALL InsertPokemon(107, 'Hitmonchan', 'Fighting', NULL, 1.4, 50.2);
CALL InsertPokemon(108, 'Lickitung', 'Normal', NULL, 1.2, 65.5);
CALL InsertPokemon(109, 'Koffing', 'Poison', NULL, 0.6, 9.5);
CALL InsertPokemon(110, 'Weezing', 'Poison', NULL, 1.2, 9.5);
CALL InsertPokemon(111, 'Rhyhorn', 'Ground', 'Rock', 1.0, 115.0);
CALL InsertPokemon(112, 'Rhydon', 'Ground', 'Rock', 1.9, 120.0);
CALL InsertPokemon(113, 'Chansey', 'Normal', NULL, 1.1, 34.6);
CALL InsertPokemon(114, 'Tangela', 'Grass', NULL, 1.0, 35.0);
CALL InsertPokemon(115, 'Kangaskhan', 'Normal', NULL, 2.2, 80.0);
CALL InsertPokemon(116, 'Horsea', 'Water', NULL, 0.4, 8.0);
CALL InsertPokemon(117, 'Seadra', 'Water', NULL, 1.8, 25.0);
CALL InsertPokemon(118, 'Goldeen', 'Water', NULL, 0.6, 15.0);
CALL InsertPokemon(119, 'Seaking', 'Water', NULL, 1.3, 39.0);
CALL InsertPokemon(120, 'Staryu', 'Water', NULL, 0.8, 34.5);
CALL InsertPokemon(121, 'Starmie', 'Water', 'Psychic', 1.1, 80.0);
CALL InsertPokemon(122, 'Mr. Mime', 'Psychic', 'Fairy', 1.3, 54.5);
CALL InsertPokemon(123, 'Scyther', 'Bug', 'Flying', 1.5, 56.0);
CALL InsertPokemon(124, 'Jynx', 'Ice', 'Psychic', 1.4, 40.6);
CALL InsertPokemon(125, 'Electabuzz', 'Electric', NULL, 1.1, 30.0);
CALL InsertPokemon(126, 'Magmar', 'Fire', NULL, 1.3, 44.5);
CALL InsertPokemon(127, 'Pinsir', 'Bug', NULL, 1.5, 55.0);
CALL InsertPokemon(128, 'Tauros', 'Normal', NULL, 1.4, 88.4);
CALL InsertPokemon(129, 'Magikarp', 'Water', NULL, 0.9, 10.0);
CALL InsertPokemon(130, 'Gyarados', 'Water', 'Flying', 6.5, 235.0);
CALL InsertPokemon(131, 'Lapras', 'Water', 'Ice', 2.5, 220.0);
CALL InsertPokemon(132, 'Ditto', 'Normal', NULL, 0.3, 4.0);
CALL InsertPokemon(133, 'Eevee', 'Normal', NULL, 0.3, 6.5);
CALL InsertPokemon(134, 'Vaporeon', 'Water', NULL, 1.0, 29.0);
CALL InsertPokemon(135, 'Jolteon', 'Electric', NULL, 0.8, 24.5);
CALL InsertPokemon(136, 'Flareon', 'Fire', NULL, 0.9, 25.0);
CALL InsertPokemon(137, 'Porygon', 'Normal', NULL, 0.8, 36.5);
CALL InsertPokemon(138, 'Omanyte', 'Rock', 'Water', 0.4, 7.5);
CALL InsertPokemon(139, 'Omastar', 'Rock', 'Water', 1.0, 35.0);
CALL InsertPokemon(140, 'Kabuto', 'Rock', 'Water', 0.5, 11.5);
CALL InsertPokemon(141, 'Kabutops', 'Rock', 'Water', 1.3, 40.5);
CALL InsertPokemon(142, 'Aerodactyl', 'Rock', 'Flying', 1.8, 59.0);
CALL InsertPokemon(143, 'Snorlax', 'Normal', NULL, 2.1, 460.0);
CALL InsertPokemon(144, 'Articuno', 'Ice', 'Flying', 1.7, 55.4);
CALL InsertPokemon(145, 'Zapdos', 'Electric', 'Flying', 1.6, 52.6);
CALL InsertPokemon(146, 'Moltres', 'Fire', 'Flying', 2.0, 60.0);
CALL InsertPokemon(147, 'Dratini', 'Dragon', NULL, 1.8, 3.3);
CALL InsertPokemon(148, 'Dragonair', 'Dragon', NULL, 4.0, 16.5);
CALL InsertPokemon(149, 'Dragonite', 'Dragon', 'Flying', 2.2, 210.0);
CALL InsertPokemon(150, 'Mewtwo', 'Psychic', NULL, 2.0, 122.0);
CALL InsertPokemon(151, 'Mew', 'Psychic', NULL, 0.4, 4.0);