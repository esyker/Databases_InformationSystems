<html>
	<body>
	<a href="insert_client_info.php">Home</a>
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
	
	$VAT_doctor = $_REQUEST['VAT_doctor'];
	$date_timestamp = $_REQUEST['date_timestamp'];
	$description = $_REQUEST['description'];
	$VAT_client = $_REQUEST['VAT_client'];
	
	$sql = $connection->prepare("INSERT INTO appointment VALUES (:VAT_doctor, :date_timestamp, :description, :VAT_client)");
	$sql->bindValue(':VAT_doctor', "$VAT_doctor");
	$sql->bindValue(':date_timestamp', "$date_timestamp");
	$sql->bindValue(':description', "$description");
	$sql->bindValue(':VAT_client', "$VAT_client");
	$sql->execute();
	
	$nrows=$sql->rowCount();
	if($nrows == 1)
		echo("<p>Appointment inserted successfully</p>");
	else if($nrows == 0)
	{
		echo("<p>Error: Appointment not inserted</p>");
		exit();
	}
	$connection = null;
?>
	</body>
</html>
