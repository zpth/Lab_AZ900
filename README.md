# ☁️ Arquitectura de alta disponibilidad en Azure

![Azure](https://img.shields.io/badge/azure-%230072C6.svg?style=for-the-badge&logo=microsoftazure&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Bash](https://img.shields.io/badge/GNU%20Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)

Este proyecto despliega una infraestructura web escalable y resistente en Microsoft Azure utilizando **Infrastructure as Code (IaC)** con Azure CLI. Simula un entorno empresarial donde el servicio debe mantenerse activo incluso si falla un servidor.

Este proyecto presenta una topología de infraestructura en Azure diseñada para alojar aplicaciones web escalables y seguras, simulando un entorno empresarial donde el servicio debe mantenerse activo incluso si falla un servidor, así mismo se limita la exposición a Internet y protege los recursos críticos mediante **Network Security Groups (NSG)**, **subredes dedicadas** y **acceso administrativo seguro**.

# 🧩 Diagrama de arquitectura

![Azure Architecture Diagram](./diagrams/architecture.png)

> El diagrama muestra el flujo completo desde el usuario hasta la base de datos, incluyendo balanceo de carga y controles de seguridad.

---

## 🏗️ Componentes

### 🔹 Azure Virtual Network (VNet)
Red privada que conecta todos los recursos de forma segura dentro de Azure.

### 🔹 Frontend Subnet
- Contiene las **máquinas virtuales web**
- Implementa un **Availability Set** para alta disponibilidad
- Protegida por un **NSG** que permite solo tráfico HTTP (80)

### 🔹 Backend Subnet
- Aloja la **lógica de negocio y base de datos**
- Aislada de Internet
- NSG configurado para **denegar tráfico externo**

### 🔹 Azure Load Balancer
- Distribuye el tráfico entrante entre las VMs web
- Evita sobrecarga y puntos únicos de falla

### 🔹 Public IP
- Punto de acceso público
- Asociada únicamente al Load Balancer

### 🔹 Storage Account (Azure Files)
- Almacenamiento compartido para archivos, recursos y logs
- Accesible solo desde la VNet

### 🔹 VPN Gateway / Azure Bastion
- Acceso administrativo seguro
- Sin exposición de puertos SSH o RDP a Internet

---
## 🚀 Despliegue

Clonar el repositorio.
```bash
git clone 
```

Ingresar al directorio y dar permisos de ejecución al script:
```bash
cd Lab-AZ900
chmod +x deploy.sh
```

Ejecutar el script:
```bash
./deploy.sh
```
