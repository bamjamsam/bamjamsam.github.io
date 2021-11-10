<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*,javax.sql.*,javax.naming.*,org.json.*,java.text.NumberFormat" %>
<%
try{

// Get JSON object from HTML page
String json = request.getParameter("data");

// Create a connection to HANA using JNDI
Context ctx = new InitialContext();
DataSource ds = (DataSource) ctx.lookup("java:/comp/env/jdbc/HANA");
Connection conn = ds.getConnection();

// Create SQL statement
String SQL = "INSERT INTO \"SEAN\".\"TEST_TABLE\" (PRODUCT, DATE, REVENUE) " + "VALUES(?, ?, ?)";

// Create PrepareStatement object
PreparedStatement pstmt = conn.prepareStatement(SQL);

// Set auto-commit to false
conn.setAutoCommit(false);

// convert the json String to a JSON object
JSONObject obj = new JSONObject(json);

// retrieve the main array of elements named "data"
JSONArray arr = obj.getJSONArray("data");

//initialize the counters
int count=0;
int totalRecords=0;
//loop through each row of data (ie. JSON Objects in the data array)
for (int i = 0; i < arr.length(); i++) {
//bring back current JSON Object
JSONObject sales = arr.getJSONObject(i);
//bring back the product element of the JSON Object
String product = sales.get("product").toString();
//bring back the date element of the JSON Object
String date = sales.get("date").toString();
//bring back the revenue element of the JSON Object
int revenue = NumberFormat.getIntegerInstance().parse(sales.getString("revenue")).intValue();

// Set these values to the PreparedStatement object - these will be used as the Values in the SQL statement
pstmt.setString( 1,product);
pstmt.setString(2,date);
pstmt.setInt( 3, revenue );
// Add it to the batch
pstmt.addBatch();
pstmt.clearParameters();
count+=1;
totalRecords+=1;

//check to see if the current count is 1000 OR the last element in the array - if true then execute the batch upload
if(count % 1000==0 || count == arr.length()) {
pstmt.executeBatch();
count=0;
}
}

//Explicitly commit statements to apply changes
conn.commit();
conn.close();

//output the result to the calling HTML page so that it is handled by the listener
out.println(totalRecords + " records uploaded successfully");
}catch(Exception e){
  out.println("Error: "+e.getLocalizedMessage());
}
%>

