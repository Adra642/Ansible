# Usa una imagen base de Fedora
FROM fedora:latest

# Instala Ansible y otras dependencias
RUN dnf install -y ansible

# Crea un directorio para el playbook
WORKDIR /ansible

# Copia el playbook al contenedor
COPY test.yml .

# Comando por defecto para mantener el contenedor en ejecución
CMD ["tail", "-f", "/dev/null"]