
#view synthetisant la table utilisateur
CREATE VIEW v_utilisatuer AS
SELECT * FROM utilisateur LIMIT 10;

#view synthetisant la table membre 
CREATE VIEW v_membre AS 
SELECT * FROM membre LIMIT 10;

#view synthetisant la table co-proprietaire
CREATE VIEW v_co_proprietaire AS
SELECT * FROM co_proprietaire LIMIT 10;

#view synthetisant la table proprietaire
CREATE VIEW v_proprietaire AS
SELECT * FROM proprietaire LIMIT 10;

#trigger se déclenchant à l’acceptation d’une invitation,supprimant le membre de tout domicile et l’ajoutant dans le nouveau
#domicile

DELIMITER $$
CREATE TRIGGER after_invitation_insert
AFTER INSERT ON inviter
FOR EACH ROW
BEGIN
	DELETE FROM contenir_utilisateur
	WHERE id_utilisateur=NEW.id_membre;
	INSERT INTO contenir_utilisateur (id_utilisateur,id_domicile) VALUES(NEW.id_membre,NEW.id_domicile);
END$$
DELIMITER ;

## trigger pour la suppression d'un proprietaire
DELIMITER $$
CREATE TRIGGER after_proprietaire_delete
AFTER DELETE ON proprietaire
FOR EACH ROW
BEGIN
	DECLARE v_id_coprop INT;
    DECLARE v_id_prop INT;
    DECLARE v_id_membre INT;
    DECLARE v_id_domicile INT;
    SELECT d.id_prop INTO v_id_prop FROM DELETED d;
	SELECT id_co_prop INTO v_id_coprop FROM
    avoir WHERE id_prorietaire=v_id_prop;
    SELECT id_domicile INTO v_id_domicile FROM avoir WHERE id_proprietaire=v_id_prop;
    IF v_id_coprop IS NOT NULL THEN
        UPDATE avoir
			SET id_proprietaire=v_id_coprop
            AND id_co_prop=NULL
            WHERE id_proprietaire=v_id_prop;
	ELSE
		DELETE FROM domiciles WHERE id_domicile=v_id_domicile;
	END IF;
END$$
DELIMITER ;

#trigger pour faire une suppression en cascade d'un domicile

DELIMITER $$
CREATE TRIGGER after_domicile_delete
AFTER DELETE ON domiciles
FOR EACH ROW
BEGIN
	DECLARE v_id_domicile INT;
    SELECT d.id_domicile INTO v_id_domicile FROM DELETED d;
    DELETE FROM pieces WHERE id_piece IN (
		SELECT id_piece FROM contenir_piece WHERE id_domicile=v_id_domicile);
END$$
DELIMITER ;

#trigger pour faire une suppression en cascade d'une piece

DELIMITER $$
CREATE TRIGGER after_piece_delete
AFTER DELETE ON pieces
FOR EACH ROW
BEGIN
	DECLARE v_id_piece INT;
    SELECT d.id_piece INTO v_id_piece FROM DELETED d;
    DELETE FROM appareils WHERE id_appareil IN (
		SELECT id_appareil FROM se_trouver WHERE id_piece=v_id_piece);
END$$
DELIMITER ;

# lister les pieces d'un domicile
DELIMITER $$
CREATE PROCEDURE list_pieces(IN p_id_domicile INTEGER)
BEGIN
	SELECT * FROM pieces WHERE id_piece IN (
		SELECT id_piece FROM contenir_piece WHERE id_domicile=p_id_domicile);
END$$
DELIMITER ;

#lister les appareils d'un domicile
DELIMITER $$
CREATE PROCEDURE list_appareils(IN p_id_domicile INTEGER)
BEGIN
	SELECT * FROM appareils WHERE id_appareil IN (
		SELECT id_appareil FROM se_trouver WHERE id_piece IN (
			SELECT id_piece FROM contenir_piece WHERE id_domicile=p_id_domicile)
            );
END $$
DELIMITER ;

# lister tous les utilisateurs d'un domicile
DELIMITER $$
CREATE PROCEDURE list_utilisateurs(IN p_id_domicile INTEGER)
BEGIN
	SELECT * FROM utilisateur WHERE id_utilisateur IN (
		SELECT id_utilisateur FROM contenir_utilisateur WHERE id_domicile=p_id_domicile);
END $$
DELIMITER ;

#lister les proprietaires et co-proprietaires
SELECT * FROM proprietaire;
SELECT * FROM co_proprietaire;

#lister les appareils d'une piece
DELIMITER $$
CREATE PROCEDURE list_appareils_piece(IN p_id_piece INTEGER)
BEGIN
	SELECT * FROM appareils WHERE id_appareil IN (
		SELECT id_appareil FROM se_trouver WHERE id_piece=p_id_piece);
END$$
DELIMITER ;

#lister toutes les invitations
SELECT * FROM inviter;
