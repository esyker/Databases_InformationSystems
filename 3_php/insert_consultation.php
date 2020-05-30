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
	
	
	
	$SOAP_S = $_REQUEST['SOAP_S'];
	$SOAP_O = $_REQUEST['SOAP_O'];
	$SOAP_A = $_REQUEST['SOAP_A'];
	$SOAP_P = $_REQUEST['SOAP_P'];
	

	$VAT_doctor = $_REQUEST['VAT_doctor'];
	$date_timestamp = $_REQUEST['date_timestamp'];
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
	
	$connection->beginTransaction();
	$sql = $connection->prepare("INSERT INTO consultation VALUES (:VAT_doctor, :date_timestamp, :SOAP_S, :SOAP_O, :SOAP_A, :SOAP_P)");
	$sql->bindValue(':VAT_doctor', "$VAT_doctor");
	$sql->bindValue(':date_timestamp', "$date_timestamp");
	$sql->bindValue(':SOAP_S', "$SOAP_S");
	$sql->bindValue(':SOAP_O', "$SOAP_O");
	$sql->bindValue(':SOAP_A', "$SOAP_A");
	$sql->bindValue(':SOAP_P', "$SOAP_P");
	$sql->execute();
	
	$nrows=$sql->rowCount();
	if($nrows == 1)
		echo("<p>Consultation inserted successfully</p>");
	else if($nrows == 0)
	{
		echo("<p>Error: Consultation not inserted</p>");
		echo("<p>Rolling Back...</p>");
		$connection->rollBack();
		exit();
	}
	
	
	foreach($_REQUEST['VATs_nurses'] as $assistant_VAT)
	{
		$sql = $connection->prepare("INSERT INTO consultation_assistant VALUES (:VAT_doctor, :date_timestamp, :assistant_VAT)");
		$sql->bindValue(':VAT_doctor', "$VAT_doctor");
		$sql->bindValue(':date_timestamp', "$date_timestamp");
		$sql->bindValue(':assistant_VAT', "$assistant_VAT");
		$sql->execute();
	
		$nrows=$sql->rowCount();
		if($nrows == 1)
			echo("<p>Consultation assistant inserted successfully</p>");
		else if($nrows == 0)
		{
			echo("<p>Error: Consultation assistant not inserted</p>");
			echo("<p>Rolling Back...</p>");
			$connection->rollBack();
			exit();
		}	
	}
	
	foreach($_REQUEST['diagnostic_codes'] as $diagnostic_ID)
	{
		$sql = $connection->prepare("INSERT INTO consultation_diagnostic VALUES (:VAT_doctor, :date_timestamp, :diagnostic_ID)");
		$sql->bindValue(':VAT_doctor', "$VAT_doctor");
		$sql->bindValue(':date_timestamp', "$date_timestamp");
		$sql->bindValue(':diagnostic_ID', "$diagnostic_ID");
		$sql->execute();
		$nrows=$sql->rowCount();
		if($nrows == 1)
			echo("<p>Diagnostic code inserted successfully</p>");
		else if($nrows == 0)
		{
			echo("<p>Error: Diagnostic code not inserted</p>");
			echo("<p>Rolling Back...</p>");
			$connection->rollBack();
			exit();
		}	
	}
	
	foreach($_REQUEST['prescription_medication'] as $medication)
	{
		list($medication_name,$medication_lab) = explode('|', $medication);
		$dosage = $_REQUEST['prescription_dosage'][$medication];
		$description = $_REQUEST['prescription_description'][$medication];
		$diagnostic_ID = $_REQUEST['prescription_diagnostic'][$medication];
		$sql = $connection->prepare("INSERT INTO prescription VALUES (:medication_name, :medication_lab, :VAT_doctor, :date_timestamp, :diagnostic_ID, :dosage, :description)");
		$sql->bindValue(':medication_name', "$medication_name");
		$sql->bindValue(':medication_lab', "$medication_lab");
		$sql->bindValue(':VAT_doctor', "$VAT_doctor");
		$sql->bindValue(':date_timestamp', "$date_timestamp");
		$sql->bindValue(':diagnostic_ID', "$diagnostic_ID");
		$sql->bindValue(':dosage', "$dosage");
		$sql->bindValue(':description', "$description");
		$sql->execute();
		$nrows=$sql->rowCount();
		if($nrows == 1)
			echo("<p>Prescription inserted successfully</p>");
		else if($nrows == 0)
		{
			echo("<p>Error: Prescription not inserted</p>");
			echo("<p>Rolling Back...</p>");
			$connection->rollBack();
			exit();
		}	
	}
	
	$connection->commit();
	echo("<p>Prescription commited to database</p>");
	$connection = null;
?>
	</body>
</html>
