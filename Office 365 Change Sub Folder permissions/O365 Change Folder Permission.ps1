[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
[System.Windows.Forms.MessageBox]::Show("This script will change the folder permissions for an office 365 user, on next screen please enter the Office 365 Admin credentials press enter to continue", "Hello") 
#Request Admin Credentials
$UserCredential = $Host.ui.PromptForCredential("Need admin credentials", "Please enter your Office 365 admin credentials.", "", "NetBiosUserName")
#Remove all existing Powershell sessions  
Get-PSSession | Remove-PSSession
#Start Powershell Session
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
#Import Session
Import-PSSession $Session
# Gather's List of Office 365 mailboxes displays them, and allows you to select One 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = "Select Mailbox"
$objForm.Size = New-Object System.Drawing.Size(400,450) 
$objForm.StartPosition = "CenterScreen"
$objForm.KeyPreview = $True
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
    {$x=$objTextBox.Text;$objForm.Close()}})
$objForm.Add_KeyDown({
if ($_.KeyCode -eq "Escape") 
    {Remove-PSSession $Session;[System.Environment]::Exit(0)}
	
	})
$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(280,380)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.Add_Click({[System.Windows.Forms.MessageBox]::Show("Operation has been canceled. This Script will now close", "Canceled");Remove-PSSession $Session;[System.Environment]::Exit(0)})
$objForm.Controls.Add($CancelButton)

$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(10,20) 
$objLabel.Size = New-Object System.Drawing.Size(350,20) 
$objLabel.Text = "Please select the mailbox you want to change permissions for:"
$objForm.Controls.Add($objLabel) 

$objListbox = New-Object System.Windows.Forms.Listbox
$objListbox.Location = New-Object System.Drawing.Size(50,40)
$objListbox.Size = New-Object System.Drawing.Size(260,320)
$objListBox.Sorted = $True
$items = Invoke-Expression "Get-Mailbox | select-object UserPrincipalName" 
foreach ($item in $items)
  {   
      [void] $objListbox.Items.Add($item.UserPrincipalName)
  }
$objForm.Controls.Add($objListbox)
$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(200,380)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.Add_Click({$mailbox=$objListBox.SelectedItem;$objForm.Close()})
$objForm.Controls.Add($OKButton)
$mailbox
$objForm.Topmost = $True

$objForm.Add_Shown({$objForm.Activate()})
[void] $objForm.ShowDialog()

$script:mailbox=$objListBox.SelectedItem

# Gather's list of user's folders displays them and allows the user to select one
 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = "Select Folder"
$objForm.Size = New-Object System.Drawing.Size(500,450) 
$objForm.StartPosition = "CenterScreen"

$objForm.KeyPreview = $True
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
    {$x=$objTextBox.Text;$objForm.Close()}})
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
    {Remove-PSSession $Session;[System.Environment]::Exit(0)}})

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(280,380)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.Add_Click({[System.Windows.Forms.MessageBox]::Show("Operation has been canceled. This Script will now close", "Canceled");Remove-PSSession $Session;[System.Environment]::Exit(0)})
$objForm.Controls.Add($CancelButton)

$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(10,20) 
$objLabel.Size = New-Object System.Drawing.Size(350,20) 
$objLabel.Text = "Please select the Folder you want to change permissions for:"
$objForm.Controls.Add($objLabel) 

$objListbox = New-Object System.Windows.Forms.Listbox
$objListbox.Location = New-Object System.Drawing.Size(50,40)
$objListbox.Size = New-Object System.Drawing.Size(380,320)
$objListBox.Sorted = $True
$items = Invoke-Expression "Get-MailboxFolderStatistics $mailbox | Select-Object FolderPath" 
foreach ($item in $items)
  {   
      [void] $objListbox.Items.Add($item.FolderPath)
  }
$objForm.Controls.Add($objListbox)
$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(200,380)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.Add_Click({$folder=$objListBox.SelectedItem;$objForm.Close()})
$objForm.Controls.Add($OKButton)
$objForm.Topmost = $True
$folder
$objForm.Add_Shown({$objForm.Activate()})
[void] $objForm.ShowDialog()

$script:folder=$objListBox.SelectedItem

# Gather's List of mailboxes to give permissions to display's and allows the user to select one
 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = "Select User to give permissions to"
$objForm.Size = New-Object System.Drawing.Size(400,450) 
$objForm.StartPosition = "CenterScreen"

$objForm.KeyPreview = $True
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
    {$x=$objTextBox.Text;$objForm.Close()}})
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
    {Remove-PSSession $Session;[System.Environment]::Exit(0)}})

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(280,380)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.Add_Click({[System.Windows.Forms.MessageBox]::Show("Operation has been canceled. This Script will now close", "Canceled");Remove-PSSession $Session;[System.Environment]::Exit(0)})
$objForm.Controls.Add($CancelButton)

$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(10,20) 
$objLabel.Size = New-Object System.Drawing.Size(350,20) 
$objLabel.Text = "Please select the user your want to give permissions to"
$objForm.Controls.Add($objLabel) 

$objListbox = New-Object System.Windows.Forms.Listbox
$objListbox.Location = New-Object System.Drawing.Size(50,40)
$objListbox.Size = New-Object System.Drawing.Size(260,320)
$objListBox.Sorted = $True
$items = Invoke-Expression "Get-Mailbox | Select-Object UserPrincipalName" 
foreach ($item in $items)
  {   
      [void] $objListbox.Items.Add($item.UserPrincipalName)
  }
$objForm.Controls.Add($objListbox)
$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(200,380)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.Add_Click({$user=$objListBox.SelectedItem;$objForm.Close()})
$objForm.Controls.Add($OKButton)
$objForm.Topmost = $True
$objForm.Add_Shown({$objForm.Activate()})
[void] $objForm.ShowDialog()

$script:user=$objListBox.SelectedItem


# Displays Permissions for user to select
 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = "Select Permissions you want to apply"
$objForm.Size = New-Object System.Drawing.Size(400,500) 
$objForm.StartPosition = "CenterScreen"

$objForm.KeyPreview = $True
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
    {$x=$objTextBox.Text;$objForm.Close()}})
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
    {Remove-PSSession $Session;[System.Environment]::Exit(0)}})

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(280,380)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.Add_Click({[System.Windows.Forms.MessageBox]::Show("Operation has been canceled. This Script will now close", "Canceled");Remove-PSSession $Session;[System.Environment]::Exit(0)})
$objForm.Controls.Add($CancelButton)

$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(10,20) 
$objLabel.Size = New-Object System.Drawing.Size(280,20) 
$objLabel.Text = "Select Permissions you want to apply"
$objForm.Controls.Add($objLabel) 

$objListbox = New-Object System.Windows.Forms.Listbox
$objListbox.Location = New-Object System.Drawing.Size(50,40)
$objListBox.Sorted = $True
$objListbox.Size = New-Object System.Drawing.Size(260,320)

      [void] $objListbox.Items.Add("PublishingEditor")
	  [void] $objListbox.Items.Add("Editor")
	  [void] $objListbox.Items.Add("PublishingAuthor")
	  [void] $objListbox.Items.Add("Author")
	  [void] $objListbox.Items.Add("NonEditingAuthor")
	  [void] $objListbox.Items.Add("Reviewer")
	  [void] $objListbox.Items.Add("Contributor")
	  [void] $objListbox.Items.Add("None")

	  
$objForm.Controls.Add($objListbox)
$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(200,380)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.Add_Click({$permission=$objListBox.SelectedItem;$objForm.Close()})
$objForm.Controls.Add($OKButton)
$objForm.Topmost = $True
$permission
$objForm.Add_Shown({$objForm.Activate()})
[void] $objForm.ShowDialog()

$script:permission=$objListBox.SelectedItem


#Final Confirmation before permissions fuction is ran
$OUTPUT=[System.Windows.Forms.MessageBox]::Show(" Please confirm You want to give $user $permission permissions to $mailbox 's $folder folder", "Confirm", 4)
if ($OUTPUT -eq "YES" ) 
{ 
#Goes through the list of every folder and sub folder and firstly removes any preexisting permissions and then apply's the new permission select by user
ForEach($f in (Get-MailboxFolderStatistics $mailbox | Where {( $_.FolderPath.Contains("$folder") -eq $True) -and ($_.FolderPath.Contains("/Calendar/Birthdays") -eq $False) -and ($_.FolderPath.Contains("/Calendar/United States holidays") -eq $False) -and ($_.FolderPath.Contains("/Calendar Logging") -eq $False)} ) ){
 $fname = "$mailbox" + ":" + $f.FolderPath.Replace("/","\");
 Remove-MailboxFolderPermission $fname -User $user -confirm: $false -EA SilentlyContinue
 Add-MailboxFolderPermission $fname -User $user -AccessRights $permission}
 Remove-PSSession $Session
 Read-Host -Prompt "Press Enter to exit"
 
 }else{
 #Cancels the script if the user selects to do so
[System.Windows.Forms.MessageBox]::Show("Operation has been canceled. This script will now close", "Canceled")
Remove-PSSession $Session
}

 

