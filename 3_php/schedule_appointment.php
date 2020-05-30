<html>
	<body>
	<a href="insert_client_info.php">Home</a>
		<form action="check_available_doctors.php" method="post">
			<h3>Schedule Appointment:</h3>
			<p>Date/Time: <input type="datetime-local" name="date_timestamp" /></p>
			<?php
				$VAT = $_GET['VAT'];
				echo("<input type=\"hidden\" name=\"VAT\" value=\"$VAT\">");
			?>
			<p><input type="submit" value="Check Available Doctors"/></p>
		</form>
	</body>
</html>
