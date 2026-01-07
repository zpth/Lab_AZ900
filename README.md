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


## 🏗️ Arquitectura

El despliegue crea los siguientes recursos de forma automatizada:

* **Grupo de Recursos:** Contenedor lógico para el ciclo de vida del proyecto.
* **Red Virtual (VNet):** Segmentación de red con subredes definidas.
* **Network Security Group (NSG):** Firewall virtual configurado para permitir solo tráfico HTTP (80).
* **Standard Load Balancer:** Distribuye el tráfico entrante entre las instancias saludables.
* **Availability Set:** Garantiza que las VMs estén en racks físicos separados (SLA 99.95%).
* **2x Virtual Machines:** Servidores Ubuntu con Nginx autoconfigurados mediante `cloud-init`.

```mermaid
graph TD
    User((Usuario)) -->|HTTP:80| LB[Azure Load Balancer]
    LB --> VM1[VM Web 01]
    LB --> VM2[VM Web 02]
    
    subgraph "Availability Set"
    VM1
    VM2
    end
    
    VM1 -.-> NSG[Network Security Group]
    VM2 -.-> NSG
