<html>
	<body>
	<a href="insert_client_info.php">Home</a>
	<h3>Appointments/Consultations</h3>
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
	
	$VAT = $_GET['VAT'];
	
	$sql = $connection->prepare("SELECT appointment.date_timestamp as date, appointment.VAT_doctor as VAT_d, employee.name as doc_name, consultation.VAT_doctor as consultation_VAT_doc FROM appointment NATURAL LEFT JOIN consultation INNER JOIN employee on employee.VAT = appointment.VAT_doctor WHERE VAT_client = :VAT order by appointment.date_timestamp");
	$sql->bindValue(':VAT', "$VAT");
	$sql->execute();
	$result = $sql->fetchAll(PDO::FETCH_ASSOC);
	if(count($result) == 0)
	{
		echo("<p>No appointments/consultations found for selected client</p>");
		$connection = null;
		exit();
	}
	echo("<table border=\"0\" cellspacing=\"5\">\n");
	echo("<tr>\n<td>Date/Time</td>\n<td>Doctor VAT</td>\n<td>Doctor Name<td>\n</tr>");
	foreach($result as $row)
	{
		echo("<tr>\n");
		
		if($row['consultation_VAT_doc'] != NULL)
		{
			echo("<td><a href=\"consultation_list.php?date_timestamp=");
			echo($row['date']);
			echo("&VAT=");
			echo($row['VAT_d']);
			echo("\">{$row['date']}</a></td>\n");
		}
		else
		{
			echo("<td>{$row['date']}</td>\n");
		}
		echo("<td>{$row['VAT_d']}</td>\n");
		echo("<td>{$row['doc_name']}</td>\n");
		if($row['consultation_VAT_doc'] == NULL)
		{
			echo("<td><a href=\"create_consultation.php?date_timestamp=");
			echo($row['date']);
			echo("&VAT_doctor=");
			echo($row['VAT_d']);
			echo("\">New Consultation</a></td>\n");
		}
		echo("</tr>\n");
	}
	echo("</table>");
	
	$connection = null;
?>
	</body>
</html>