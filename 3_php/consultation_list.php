<html>
	<body>
	<a href="insert_client_info.php">Home</a>
	<h3>Consultation</h3>
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
	
	$VAT_doctor = $_GET['VAT'];
	$date_timestamp = $_GET['date_timestamp'];
	
	$sql = $connection->prepare("SELECT * from consultation WHERE VAT_doctor = :VAT_doctor AND date_timestamp = :date_timestamp");
	$sql->bindValue(':VAT_doctor', "$VAT_doctor");
	$sql->bindValue(':date_timestamp', "$date_timestamp");
	$sql->execute();
	$result = $sql->fetch(PDO::FETCH_ASSOC);
	if(count($result) == 0)
	{
		echo("<p>No consultation found for selected parameters</p>");
		$connection = null;
		exit();
	}
	
	echo("<p>Subjective observation: {$result['SOAP_S']}</p>");
	echo("<p>Objective observation: {$result['SOAP_O']}</p>");
	echo("<p>Assessment: {$result['SOAP_A']}</p>");
	echo("<p>Plan: {$result['SOAP_P']}</p>");
	
	
	
	
	$sql = $connection->prepare("SELECT * from consultation_assistant NATURAL JOIN employee WHERE VAT_nurse = VAT AND VAT_doctor = :VAT_doctor AND date_timestamp = :date_timestamp");
	$sql->bindValue(':VAT_doctor', "$VAT_doctor");
	$sql->bindValue(':date_timestamp', "$date_timestamp");
	$sql->execute();
	$result = $sql->fetchAll(PDO::FETCH_ASSOC);
	if(count($result) == 0)
	{
		echo("<p><br>There are no assistant nurses for this consultation</p>");
	}
	else
	{
		echo("<p><br>Assistant nurses:</p>");
		foreach($result as $row)
		{
			echo("<p>{$row['name']} (VAT: {$row['VAT']})</p>");
		}
	}
	
	
	$sql = $connection->prepare("SELECT consultation_diagnostic.ID, prescription.description, name, lab, dosage, diagnostic_code.description as ddescription from consultation NATURAL JOIN consultation_diagnostic NATURAL LEFT OUTER JOIN prescription LEFT JOIN diagnostic_code on diagnostic_code.ID = consultation_diagnostic.ID WHERE VAT_doctor = :VAT_doctor AND date_timestamp = :date_timestamp");
	$sql->bindValue(':VAT_doctor', "$VAT_doctor");
	$sql->bindValue(':date_timestamp', "$date_timestamp");
	$sql->execute();
	$result = $sql->fetchAll(PDO::FETCH_ASSOC);
	if(count($result) == 0)
	{
		echo("<p><br>There are no diagnostics/prescriptions found for this consultation</p>");
		
	}
	else
	{
	
	
		echo("<table border=\"0\" cellspacing=\"5\">\n");
		echo("<tr>\n<td>Diagnostic ID</td>\n<td>Diagnostic Description</td>\n<td>Medication Name</td>\n<td>Medication Lab</td>\n<td>Medication Dosage</td>\n<td>Medication Description</td>\n");
		foreach($result as $row)
		{
			echo("<tr>\n");	
			if($row['ID'] != NULL)
				echo("<td>{$row['ID']}</td>\n");
			else
				echo("<td>---</td>\n");
			if($row['ddescription'] != NULL)
				echo("<td>{$row['ddescription']}</td>\n");
			else
				echo("<td>---</td>\n");
			if($row['name'] != NULL)
				echo("<td>{$row['name']}</td>\n");
			else
				echo("<td>---</td>\n");
			if($row['lab'] != NULL)
				echo("<td>{$row['lab']}</td>\n");
			else
				echo("<td>---</td>\n");
			if($row['dosage'] != NULL)
				echo("<td>{$row['dosage']}</td>\n");
			else
				echo("<td>---</td>\n");
			if($row['description'] != NULL)
				echo("<td>{$row['description']}</td>\n");
			else
				echo("<td>---</td>\n");
			
			echo("</tr>\n");
		}
		echo("</table>\n");
	}
	
	echo("<a href=\"create_dental_charting.php?VAT_doctor=$VAT_doctor&date_timestamp=$date_timestamp\">Create Dental Charting</a>");
	$connection = null;
?>

	</body>
</html>