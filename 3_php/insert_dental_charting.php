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
	$procedure_name = $_REQUEST['procedure_name'];
	$procedure_type = $_REQUEST['procedure_type'];
	$procedure_description = $_REQUEST['procedure_description'];
	
	if($VAT_doctor == '' || $VAT_doctor == NULL)
	{
		echo("<p>Error: VAT_doctor must not be empty</p>");
		exit();
	}
	if($date_timestamp == '' || $date_timestamp == NULL)
	{
		echo("<p>Error: date_timestamp must not be empty</p>");
		exit();
	}
	if($procedure_name == '' || $procedure_name == NULL)
	{
		echo("<p>Error: Procedure Name must not be empty</p>");
		exit();
	}	


	$connection->beginTransaction();	
	$sql = $connection->prepare("INSERT INTO procedure_ VALUES (:procedure_name, :procedure_type)");
	$sql->bindValue(':procedure_name', "$procedure_name");
	$sql->bindValue(':procedure_type', "$procedure_type");
	$sql->execute();
	
	$nrows=$sql->rowCount();
	if($nrows == 1)
		echo("<p>Procedure inserted successfully</p>");
	else if($nrows == 0)
		echo("<p>Procedure not inserted</p>");
	
	$sql = $connection->prepare("INSERT INTO procedure_in_consultation VALUES (:procedure_name, :VAT_doctor, :date_timestamp, :procedure_description)");
	$sql->bindValue(':procedure_name', "$procedure_name");
	$sql->bindValue(':VAT_doctor', "$VAT_doctor");
	$sql->bindValue(':date_timestamp', "$date_timestamp");
	$sql->bindValue(':procedure_description', "$procedure_description");
	$sql->execute();
	$nrows=$sql->rowCount();
	if($nrows == 1)
		echo("<p>Procedure in consultation inserted successfully</p>");
	else if($nrows == 0)
	{
		echo("<p>Error: Procedure in consultation not inserted</p>");
		echo("<p>Rolling Back...</p>");
		$connection->rollBack();
		exit();
	}
	
	foreach($_REQUEST['teeth'] as $tooth)
	{
		list($tooth_quadrant,$tooth_number) = explode('|', $tooth);
		$measure_tooth = $_REQUEST['measure_tooth'][$tooth];
		if($measure_tooth == '' || $measure_tooth == NULL)
		{
			echo("<p>Error: Tooth gap is not valid</p>");
			echo("<p>Rolling Back...</p>");
			$connection->rollBack();
			exit();
		}	
		$description_tooth = $_REQUEST['description_tooth'][$tooth];
		$sql = $connection->prepare("INSERT INTO procedure_charting VALUES (:procedure_name, :VAT_doctor, :date_timestamp, :tooth_quadrant, :tooth_number, :description_tooth, :measure_tooth)");
		$sql->bindValue(':procedure_name', "$procedure_name");
		$sql->bindValue(':VAT_doctor', "$VAT_doctor");
		$sql->bindValue(':date_timestamp', "$date_timestamp");
		$sql->bindValue(':tooth_quadrant', "$tooth_quadrant");
		$sql->bindValue(':tooth_number', "$tooth_number");
		$sql->bindValue(':description_tooth', "$description_tooth");
		$sql->bindValue(':measure_tooth', $measure_tooth);
		$sql->execute();
		$nrows=$sql->rowCount();
		if($nrows == 1)
			echo("<p>Tooth in dental charting inserted successfully</p>");
		else if($nrows == 0)
		{
			echo("<p>Error: Tooth in dental charting not inserted</p>");
			echo("<p>Rolling Back...</p>");
			$connection->rollBack();
			exit();
		}
	}
	
	$connection->commit();
	echo("<p>Dental charting commited to database</p>");
	$connection = null;
?>
	</body>
</html>
