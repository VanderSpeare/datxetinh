# datxetinh
cd E:\DATXE\datxetinh-backend
//server.js
node server.js
uvicorn server:app --host 0.0.0.0 --port 3000


//server.py
pip install fastapi uvicorn pymongo pandas sqlite3 pyjwt
uvicorn server:app --host 0.0.0.0 --port 8000



trong \datxetinh\lib\core\Constants.dart
3: Verify CORS in Server.js
Ensure the Node.js
app.use(cors({ origin: ['http://localhost:56966', 'http://192.168.50.7:56966'] })); // thay bằng IP máy hiện tại ( wifi - ipv4)