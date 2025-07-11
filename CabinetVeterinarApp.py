import pyodbc
from flask import Flask, request, session, jsonify
import socket
from flask_cors import CORS
from werkzeug.security import generate_password_hash, check_password_hash
from contextlib import contextmanager


def get_origins():
    origins = ["http://127.0.0.1:5500"]
    host_ips = socket.gethostbyname_ex(socket.gethostname())[2]
    local_ip = next((ip for ip in host_ips if ip.startswith("192.168.")), None)
    if local_ip:
        origins.append(f"http://{local_ip}:5500")
    return origins


app = Flask(__name__)
app.config.from_pyfile('config.py')
CORS(app, origins=get_origins(), supports_credentials=True)


@contextmanager
def db_connect():
    db = cursor = None
    try:
        db = pyodbc.connect('DRIVER={SQL Server};'
                            'SERVER=MIHNEA\\SQLEXPRESS;'
                            'DATABASE=CabinetVeterinar;'
                            'Trusted_Connection=yes;')
        db.autocommit = True
        cursor = db.cursor()
        yield cursor
    except pyodbc.Error as e:
        print(e)
        raise
    finally:
        if cursor:
            cursor.close()
        if db:
            db.close()


@app.route('/login', methods=['POST'])
def login():
    data = request.json
    username = data.get('username')
    password = data.get('password')

    try:
        with db_connect() as cursor:
            query = """
            SELECT U.Parola,
                CASE
                    WHEN S.Username IS NOT NULL THEN 'Stapan'
                    WHEN M.Username IS NOT NULL THEN 'Medic'
                END
            FROM Utilizatori U
                LEFT JOIN Stapani S ON U.Username=S.Username
                LEFT JOIN Medici M ON U.Username=M.Username
            WHERE U.Username=?
            """
            cursor.execute(query, username)
            user = cursor.fetchone()
    except:
        return "", 500
    else:
        if not user or not check_password_hash(user[0], password):
            return "", 401

        session['username'] = username
        if user[1]:
            session['role'] = user[1]
            return user[1]+".html", 200
        return "", 403


@app.route('/register', methods=['POST'])
def register():
    data = request.json
    username = data.get('username')
    password = data.get('password')

    try:
        with db_connect() as cursor:
            query_unique = """
            SELECT COUNT(*)
            FROM Utilizatori
            WHERE Username=?
            """
            cursor.execute(query_unique, username)
            if cursor.fetchone()[0]:
                return "", 409

            query_insert = """
            INSERT INTO Utilizatori(Username,Parola)
            VALUES (?,?)
            """
            cursor.execute(query_insert, username,
                           generate_password_hash(password))
    except:
        return "", 500
    else:
        session['username'] = username
        return "", 201


@app.route('/register/stapan', methods=['POST'])
def register_stapan():
    if 'username' not in session or 'role' in session:
        return "", 403

    data = request.json
    nume = data.get('nume')
    prenume = data.get('prenume')
    telefon = data.get('telefon')
    email = data.get('email')
    adresa = data.get('adresa')

    try:
        with db_connect() as cursor:
            query = """
            INSERT INTO Stapani(Nume,Prenume,Telefon,Email,Adresa,Username)
            VALUES (?,?,?,?,?,?)
            """
            cursor.execute(query, nume, prenume,
                           telefon, email, adresa, session['username'])
    except:
        return "", 500
    else:
        return "", 201


@app.route('/register/medic', methods=['POST'])
def register_medic():
    if 'username' not in session or 'role' in session:
        return "", 403

    data = request.json
    secret_key = data.get('secretKey')
    nume = data.get('nume')
    prenume = data.get('prenume')
    specializare = data.get('specializare')
    email = data.get('email')

    if secret_key != app.config['MEDIC_REGISTRATION_KEY']:
        return "", 400

    try:
        with db_connect() as cursor:
            query = """
            INSERT INTO Medici(Nume,Prenume,Specializare,Email,Username)
            VALUES (?,?,?,?,?)
            """
            cursor.execute(query, nume, prenume,
                           specializare, email, session['username'])
    except:
        return "", 500
    else:
        return "", 201


@app.route('/stapan/animale', methods=['GET'])
def get_animale_stapan():
    if 'username' not in session or session['role'] != "Stapan":
        return "", 403

    try:
        with db_connect() as cursor:
            query = """
            SELECT A.Nume,A.Specie,A.Rasa,A.DataNasterii,A.Sex,A.Greutate
            FROM Animale A JOIN Stapani S ON A.StapanID=S.StapanID
            WHERE S.Username=?
            """
            cursor.execute(query, session['username'])
            animale = cursor.fetchall()
    except:
        return "", 500
    else:
        return jsonify([tuple(row) for row in animale]), 200


@app.route('/stapan/consultatii', methods=['GET'])
def get_consultatii_stapan():
    if 'username' not in session or session['role'] != "Stapan":
        return "", 403

    try:
        with db_connect() as cursor:
            query = """
            SELECT A.Nume,C.DataConsultatiei,C.Diagnostic,C.Observatii,M.Nume+' '+M.Prenume
            FROM Consultatii C
                JOIN Animale A ON C.AnimalID=A.AnimalID
                JOIN Stapani S ON A.StapanID=S.StapanID
                JOIN Medici M ON C.MedicID=M.MedicID
            WHERE S.Username=?
            """
            cursor.execute(query, session['username'])
            consultatii = cursor.fetchall()
    except:
        return "", 500
    else:
        return jsonify([tuple(row) for row in consultatii]), 200


@app.route('/stapan/vaccinari', methods=['GET'])
def get_vaccinari_stapan():
    if 'username' not in session or session['role'] != "Stapan":
        return "", 403

    try:
        with db_connect() as cursor:
            query = """
            SELECT A.Nume,V.Nume,V.TipAdministrare,V.Doza,AV.DataVaccinarii
            FROM AnimaleVaccinuri AV
                JOIN Vaccinuri V ON AV.VaccinID=V.VaccinID
                JOIN Animale A ON AV.AnimalID=A.AnimalID
                JOIN Stapani S ON A.StapanID=S.StapanID
            WHERE S.Username=?
            """
            cursor.execute(query, session['username'])
            vaccinari = cursor.fetchall()
    except:
        return "", 500
    else:
        return jsonify([tuple(row) for row in vaccinari]), 200


@app.route('/stapan/vaccinari/delete', methods=['DELETE'])
def delete_vaccinare_stapan():
    if 'username' not in session or session['role'] != "Stapan":
        return "", 403

    data = request.json
    numeAnimal = data.get('numeAnimal')
    numeVaccin = data.get('numeVaccin')

    try:
        with db_connect() as cursor:
            query = """
            DELETE AV
            FROM AnimaleVaccinuri AV
                JOIN Animale A ON AV.AnimalID=A.AnimalID
                JOIN Stapani S ON A.StapanID=S.StapanID
                JOIN Vaccinuri V ON AV.VaccinID=V.VaccinID
            WHERE A.Nume=? AND S.Username=? AND V.Nume=?
            """
            cursor.execute(query, numeAnimal, session['username'], numeVaccin)
            if cursor.rowcount == 0:
                return "", 404
    except:
        return "", 500
    else:
        return "", 204


@app.route('/stapan/cont', methods=['GET'])
def get_cont_stapan():
    if 'username' not in session or session['role'] != "Stapan":
        return "", 403

    try:
        with db_connect() as cursor:
            query = """
            SELECT Nume,Prenume,Telefon,Email,Adresa
            FROM Stapani
            WHERE Username=?
            """
            cursor.execute(query, session['username'])
            cont = cursor.fetchone()
    except:
        return "", 500
    else:
        return jsonify([tuple(cont)]), 200


@app.route('/stapan/cont/update', methods=['PATCH'])
def update_cont_stapan():
    if 'username' not in session or session['role'] != "Stapan":
        return "", 403

    data = request.json
    numeColoana = data.get('numeColoana')
    nouaValoare = data.get('nouaValoare')

    if numeColoana not in ['Nume', 'Prenume', 'Telefon', 'Email', 'Adresa']:
        return "", 400

    try:
        with db_connect() as cursor:
            query = f"""
            UPDATE Stapani
            SET {numeColoana}=?
            WHERE Username=?
            """
            cursor.execute(query, nouaValoare, session['username'])
    except:
        return "", 500
    else:
        return "", 204


@app.route('/medic/stapaniAnimale', methods=['GET'])
def get_stapaniAnimale_medic():
    if 'username' not in session or session['role'] != "Medic":
        return "", 403

    try:
        with db_connect() as cursor:
            query = """
            SELECT S.Nume,S.Prenume,S.Telefon,S.Email,A.Nume,A.Specie,A.Rasa
            FROM Stapani S JOIN Animale A ON S.StapanID=A.StapanID
            """
            cursor.execute(query)
            stapaniAnimale = cursor.fetchall()
    except:
        return "", 500
    else:
        return jsonify([tuple(row) for row in stapaniAnimale]), 200


@app.route('/medic/stapaniAnimale/<int:nrAnimale>', methods=['GET'])
def getFiltered_stapaniAnimale_medic(nrAnimale):
    if 'username' not in session or session['role'] != "Medic":
        return "", 403

    try:
        with db_connect() as cursor:
            query = """
            SELECT S.Nume,S.Prenume,S.Telefon,S.Email,A1.Nume,A1.Specie,A1.Rasa
            FROM Stapani S JOIN Animale A1 ON S.StapanID=A1.StapanID
            WHERE ?<=(
                SELECT COUNT(*)
                FROM Animale A2
                WHERE A2.StapanID=S.StapanID
            )
            """
            cursor.execute(query, nrAnimale)
            stapaniAnimale = cursor.fetchall()
    except:
        return "", 500
    else:
        return jsonify([tuple(row) for row in stapaniAnimale]), 200


@app.route('/medic/consultatii', methods=['GET'])
def get_consultatii_medic():
    if 'username' not in session or session['role'] != "Medic":
        return "", 403

    try:
        with db_connect() as cursor:
            query = """
            SELECT A.Nume,C.DataConsultatiei,C.Diagnostic,C.Observatii
            FROM Consultatii C
                JOIN Animale A ON C.AnimalID=A.AnimalID
                JOIN Medici M ON C.MedicID=M.MedicID
            WHERE M.Username=?
            """
            cursor.execute(query, session['username'])
            consultatii = cursor.fetchall()
    except:
        return "", 500
    else:
        return jsonify([tuple(row) for row in consultatii]), 200


@app.route('/medic/vaccinari', methods=['GET'])
def get_vaccinari_medic():
    if 'username' not in session or session['role'] != "Medic":
        return "", 403

    try:
        with db_connect() as cursor:
            query = """
            SELECT A.Nume,V.Nume,V.TipAdministrare,V.Doza,AV.DataVaccinarii
            FROM AnimaleVaccinuri AV
                JOIN Vaccinuri V ON AV.VaccinID=V.VaccinID
                JOIN Animale A ON AV.AnimalID=A.AnimalID
                JOIN Medici M ON AV.MedicID=M.MedicID
            WHERE M.Username=?
            """
            cursor.execute(query, session['username'])
            vaccinari = cursor.fetchall()
    except:
        return "", 500
    else:
        return jsonify([tuple(row) for row in vaccinari]), 200


@app.route('/medic/vaccinari/<string:numeStapan>', methods=['GET'])
def getFiltered_vaccinari_medic(numeStapan):
    if 'username' not in session or session['role'] != "Medic":
        return "", 403
    try:
        with db_connect() as cursor:
            query = """
            SELECT A.Nume,V.Nume,V.TipAdministrare,V.Doza,AV.DataVaccinarii
            FROM AnimaleVaccinuri AV
                JOIN Vaccinuri V ON AV.VaccinID=V.VaccinID
                JOIN Animale A ON AV.AnimalID=A.AnimalID
                JOIN Medici M ON AV.MedicID=M.MedicID
            WHERE M.Username=? AND A.StapanID IN (
                SELECT S.StapanID
                FROM Stapani S
                WHERE S.Nume=?
            )
            """
            cursor.execute(query, session['username'], numeStapan)
            vaccinari = cursor.fetchall()
    except:
        return "", 500
    else:
        return jsonify([tuple(row) for row in vaccinari]), 200


@app.route('/medic/vaccinari/update', methods=['PATCH'])
def update_vaccinare_medic():
    if 'username' not in session or session['role'] != "Medic":
        return "", 403

    data = request.json
    numeAnimal = data.get('numeAnimal')
    numeVaccinVechi = data.get('numeVaccinVechi')
    numeVaccinNou = data.get('numeVaccinNou')

    try:
        with db_connect() as cursor:
            query = """
            UPDATE AV
            SET AV.VaccinID=(
                SELECT V1.VaccinID
                FROM Vaccinuri V1
                WHERE V1.Nume=?
            )
            FROM AnimaleVaccinuri AV
                JOIN Animale A ON AV.AnimalID=A.AnimalID
                JOIN Medici M ON AV.MedicID=M.MedicID
                JOIN Vaccinuri V2 ON AV.VaccinID=V2.VaccinID
            WHERE A.Nume=? AND M.Username=? AND V2.Nume=?
            """
            cursor.execute(query, numeVaccinNou, numeAnimal,
                           session['username'], numeVaccinVechi)
            if cursor.rowcount == 0:
                return "", 404
    except:
        return "", 500
    else:
        return "", 204


@app.route('/medic/tratamenteMedicamente', methods=['GET'])
def get_tratamenteMedicamente_medic():
    if 'username' not in session or session['role'] != "Medic":
        return "", 403

    try:
        with db_connect() as cursor:
            query = """
            SELECT T.TratamentID,A.Nume,T.TipTratament,T.Durata,
                CASE WHEN T.Stare=1 THEN 'Activ' ELSE 'Terminat' END,
                M.Nume,M.Descriere,M.Contraindicatii,M.Doza,M.Forma
            FROM TratamenteMedicamente TM
                JOIN Tratamente T ON TM.TratamentID=T.TratamentID
                JOIN Medicamente M ON TM.MedicamentID=M.MedicamentID
                JOIN Consultatii C ON T.ConsultatieID=C.ConsultatieID
                JOIN Animale A ON C.AnimalID=A.AnimalID
                JOIN Medici Med ON C.MedicID=Med.MedicID
            WHERE Med.Username=?
            """
            cursor.execute(query, session['username'])
            tratamenteMedicamente = cursor.fetchall()
    except:
        return "", 500
    else:
        return jsonify([tuple(row) for row in tratamenteMedicamente]), 200


@app.route('/medic/tratamenteMedicamente/delete', methods=['DELETE'])
def delete_tratamentMedicament_medic():
    if 'username' not in session or session['role'] != "Medic":
        return "", 403

    data = request.json
    tratamentID = data.get('tratamentID')
    numeMedicament = data.get('numeMedicament')

    try:
        with db_connect() as cursor:
            query = """
            DELETE TM
            FROM TratamenteMedicamente TM
                JOIN Tratamente T ON TM.TratamentID=T.TratamentID
                JOIN Medicamente M ON TM.MedicamentID=M.MedicamentID
                JOIN Consultatii C ON T.ConsultatieID=C.ConsultatieID
                JOIN Medici Med ON C.MedicID=Med.MedicID
            WHERE TM.TratamentID=? AND M.Nume=? AND Med.Username=?
            """
            cursor.execute(query, tratamentID, numeMedicament,
                           session['username'])
            if cursor.rowcount == 0:
                return "", 404
    except:
        return "", 500
    else:
        return "", 204


@app.route('/logout', methods=['POST'])
def logout():
    session.clear()
    return "", 204


if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True, use_reloader=True)
