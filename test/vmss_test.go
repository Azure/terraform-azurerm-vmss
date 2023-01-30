package test

import (
	"bytes"
	"fmt"
	"log"

	//"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"golang.org/x/crypto/ssh"
)

func TestTerraformVmss(t *testing.T) {
	t.Parallel()

	workingDir := "./fixtures"
	uniqueID := random.UniqueId()
	uniquelower := strings.ToLower(string(uniqueID))
	scalesetname := fmt.Sprintf("vm%s", uniquelower)
	dns := fmt.Sprintf("azvmss%s", uniquelower)

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer test_structure.RunTestStage(t, "destory", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)
		//Deleting the linux scaleset separately to avoid dependancy issues
		targetlin := []string{"azurerm_virtual_machine_scale_set.standard-linux-vmss"}
		terraformOptions.Targets = targetlin
		terraform.Destroy(t, terraformOptions)
		//Deleting the windows scaleset separately to avoid dependancy issues
		targetwin := []string{"azurerm_virtual_machine_scale_set.standard-windows-vmss"}
		terraformOptions.Targets = targetwin
		terraform.Destroy(t, terraformOptions)
		//Deleting rest of the resources
		terraformOptions.Targets = []string{}
		terraform.Destroy(t, terraformOptions)
	})

	// Deploy the example
	test_structure.RunTestStage(t, "deploy", func() {
		terraformOptions := configureTerraformOptions(t, workingDir, scalesetname, dns)
		test_structure.SaveTerraformOptions(t, workingDir, terraformOptions)

		terraform.InitAndApply(t, terraformOptions)
	})

	// Make sure we can SSH to virtual machines directly from the public Internet
	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)
		validate(t, terraformOptions)
	})
}

func configureTerraformOptions(t *testing.T, workingDir string, scalesetname string, dns string) *terraform.Options {

	terraformOptions := &terraform.Options{
		TerraformDir: workingDir,
		Vars: map[string]interface{}{
			"dns_name":      dns,
			"scaleset_name": scalesetname,
		},
	}
	return terraformOptions
}

func validate(t *testing.T, terraformOptions *terraform.Options) {
	publicIP := terraform.Output(t, terraformOptions, "lb_publicip_id")
	connectionstring := fmt.Sprintf("%s:50002", publicIP)
	sshConfig := &ssh.ClientConfig{
		User: "azureuser",
		Auth: []ssh.AuthMethod{
			ssh.Password("Welcome@123456"),
		},
		HostKeyCallback: ssh.InsecureIgnoreHostKey(),
	}
	connection, err := ssh.Dial("tcp", connectionstring, sshConfig)
	if err != nil {
		log.Fatal("Failed to dial: ", err)
	}
	session, err := connection.NewSession()
	if err != nil {
		log.Fatal("Failed to create session: ", err)
	}
	defer session.Close()
	var b bytes.Buffer
	session.Stdout = &b
	if err := session.Run("hostname"); err != nil {
		panic("Failed to run: " + err.Error())
	}
	fmt.Println(b.String())
}
