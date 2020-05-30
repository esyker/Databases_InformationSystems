<html>
	<body>
	<a href="insert_client_info.php">Home</a>
		<form action="insert_appointment.php" method="post"> 
			<h3>Select Doctor</h3>
			
			

<?php
	$host = "db.tecnico.ulisboa.pt";
	$user = "ist186980";
	$pass = "tcsa6810";
	$dsn = "mysql:host=$host;dbname=$user";
	try
	{
		$connection = new PDO($dsn, $user, $pass);
	}
	catch(PDOException $exception)
	{
		echo("<p>Error: ");
		echo($exception->getMessage());
		echo("</p>");
		exit();
	}
	
	$VAT_client = $_REQUEST['VAT'];
	$date_timestamp = date('Y-m-d H:i:s',strtotime($_REQUEST['date_timestamp']));
	$dateTimestamp = strtotime($_REQUEST['date_timestamp']);
	if($VAT_client == '' || $VAT_client == NULL)
	{
		echo("<p>Error: VAT must not be empty</p>");
		exit();
	}
	if($date_timestamp == '' || $date_timestamp == NULL)
	{
		echo("<p>Error: Date/Time must not be empty</p>");
		exit();
	}
	if(date('i', $dateTimestamp) != 0 || date('s', $dateTimestamp) != 0 || date('H', $dateTimestamp) < 9 || date('H', $dateTimestamp) > 17)
	{		
		echo("<p>Error: Time must be an exact hour between 9am and 5pm</p>");
		exit();
	}
	if($dateTimestamp < time())
	{
		echo("<p>Error: Date/Time must be in the future</p>");
		exit();
	}
	
	echo("<p>Doctor:<select name=\"VAT_doctor\">");
	$sql = $connection->prepare("SELECT * FROM doctor NATURAL JOIN employee d WHERE NOT EXISTS(SELECT * FROM appointment WHERE d.VAT = appointment.VAT_doctor AND appointment.date_timestamp = :date_timestamp)");
	$sql->bindValue(':date_timestamp', "$date_timestamp");
	$sql->execute();
	$result = $sql->fetchAll(PDO::FETCH_ASSOC);
	if(count($result) == 0)
	{
		echo("<p>No doctors available for selected date and time</p>");
		exit();
	}
	foreach($result as $row)
	{
		$VAT_doctor = $row['VAT'];
		$doctor_name = $row['name'];
		echo("<option value=$VAT_doctor>$doctor_name (VAT: $VAT_doctor)</option>");
	}
	echo("</select>");
	echo("</p>");
	echo("<input type=\"hidden\" name=\"VAT_client\" value=\"$VAT_client\">");
	echo("<input type=\"hidden\" name=\"date_timestamp\" value=\"$date_timestamp\">");
	echo("<p>Description: <input type=\"text\" name=\"description\"/></p>");
	echo("<p><input type=\"submit\" value=\"Create Appointment\"/></p>");
	$connection = null;
	
?>
			
			
		</form>
	</body>
</html>