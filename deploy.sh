#!/bin/bash

# 1. Variables
RG="Proyecto-Azure"
Location="eastus2"
VNet="Cluster-VNet"
SubnetFront="Frontend-Subnet"
AvSet="Web-AvSet"
LB="Web-LoadBalancer"
VMSize="Standard_D2s_v3"

echo "--- 1. Creando grupo de recursos ---"
az group create --name $RG --location $Location

echo "--- 2. Configurando red y seguridad ---"
az network vnet create --resource-group $RG --name $VNet --address-prefix 10.0.0.0/16 --subnet-name $SubnetFront --subnet-prefix 10.0.1.0/24
az network nsg create --resource-group $RG --name Web-NSG
az network nsg rule create --resource-group $RG --nsg-name Web-NSG --name Allow-HTTP --priority 100 --destination-port-ranges 80 --protocol Tcp --access Allow
az network vnet subnet update --resource-group $RG --vnet-name $VNet --name $SubnetFront --network-security-group Web-NSG

echo "--- 3. Desplegando load balancer ---"
az network public-ip create --resource-group $RG --name LB-PublicIP --sku Standard
az network lb create --resource-group $RG --name $LB --sku Standard --public-ip-address LB-PublicIP --frontend-ip-name FrontEndPool --backend-pool-name BackEndPool
az network lb probe create --resource-group $RG --lb-name $LB --name HttpProbe --protocol Tcp --port 80
az network lb rule create --resource-group $RG --lb-name $LB --name LBRule --protocol Tcp --frontend-port 80 --backend-port 80 --frontend-ip-name FrontEndPool --backend-pool-name BackEndPool --probe-name HttpProbe 

echo "--- 4. Creando archivo server-init.txt ---"
cat <<EOF > server-init.txt
#cloud-config
package_update: true
package_upgrade: true

packages:
  - nginx

runcmd:
  - |
    HOSTNAME=\$(hostname)
    cat <<HTML > /var/www/html/index.html
    <!DOCTYPE html>
    <html lang="es">
    <head>
        <meta charset="UTF-8">
        <title>Azure Load Balancer</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                background-color: #f3f6f9;
                text-align: center;
                padding-top: 80px;
            }
            .box {
                display: inline-block;
                padding: 30px;
                border: 2px solid #0078D4;
                border-radius: 10px;
                background-color: #ffffff;
            }
            h1 {
                color: #0078D4;
            }
            .server {
                margin-top: 15px;
                font-size: 20px;
                font-weight: bold;
                color: #333333;
            }
        </style>
    </head>
    <body>
        <div class="box">
            <h1>Servidor Web en Azure</h1>
            <div class="server">Estas accediendo al servidor: \$HOSTNAME</div>
        </div>
    </body>
    </html>
    HTML
  - systemctl restart nginx
EOF



echo "--- 5. Desplegando VMs (Esto puede tardar unos minutos) ---"
az vm availability-set create --resource-group $RG --name $AvSet

for i in 1 2; do
  echo "Creando VM $i..."
  az vm create \
    --resource-group $RG \
    --name WebServer0$i \
    --image Ubuntu2204 \
    --size $VMSize \
    --vnet-name $VNet \
    --subnet $SubnetFront \
    --nsg "" \
    --availability-set $AvSet \
    --custom-data server-init.txt \
    --admin-username azureuser \
    --generate-ssh-keys --no-wait
done

# Esperamos a que las VMs terminen de crearse para conectar las NICs
echo "Esperando a que las VMs estén listas..."
sleep 180

echo "--- 6. Conectando VMs al load balancer ---"
for i in 1 2; do
  NIC_NAME="WebServer0${i}VMNic"
  # Obtener el nombre real de la configuración IP dinámicamente
  IP_CONFIG=$(az network nic show --resource-group $RG --name $NIC_NAME --query "ipConfigurations[0].name" --output tsv)
  
  az network nic ip-config address-pool add \
    --address-pool BackEndPool \
    --lb-name $LB \
    --nic-name $NIC_NAME \
    --resource-group $RG \
    --ip-config-name $IP_CONFIG
done

echo "--- ¡DESPLIEGUE FINALIZADO! ---"
az network public-ip show --resource-group $RG --name LB-PublicIP --query ipAddress --output tsv

