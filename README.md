# sshuttle server for Docker

by MuchLearning

This image contains all that is needed to log in using
[sshuttle](https://github.com/apenwarr/sshuttle).  It may also be used as a
generic ssh server, for example, for port forwarding, etc.  It is particularly
useful for environments such as kubernetes or Docker Cloud that provide a
private network between containers.

## How to use it

1. set the environment variable `AUTHORIZED_KEYS` to the key(s) that should be
   allowed to log in

2. mount a volume at /etc/ssh/keys which is a directory with the host keys.
   The key filenames should end with `key`.  Alternatively, add a layer to
   this image that includes that directory.  Just don't push the image to a
   public repository, or else your host keys will become public.

3. run the image, and publish port 22

4. you can now ssh in as the user sshuttle

## Example kubernetes deployment

    apiVersion: v1
    kind: Secret
    metadata:
      name: sshuttle
      namespace: sshuttle
    type: Opaque
    data:
      ecdsakey: [base64-encoded key]
      ed25519key: [base64-encoded key]
      rsakey: [base64-encoded key]

    ---
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: sshuttle
      namespace: sshuttle
    data:
      authorizedkeys: "[user's public key]"

    ---
    apiVersion: extensions/v1beta1
    kind: Deployment
    metadata:
      name: sshuttle
      namespace: sshuttle
    spec:
      replicas: 1
      template:
        metadata:
          labels:
            role: sshuttle
        spec:
          containers:
          - name: sshuttle
            image: muchlearning/sshuttle-server:latest
            ports:
            - containerPort: 22
            env:
            - name: AUTHORIZED_KEYS
              valueFrom:
                configMapKeyRef:
                  name: sshuttle
                  key: authorizedkeys
            volumeMounts:
            - name: keys
              mountPath: /etc/ssh/keys
          volumes:
          - name: keys
            secret:
              secretName: sshuttle

    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: sshuttle
      namespace: sshuttle
      labels:
        role: sshuttle
    spec:
      selector:
        role: sshuttle
      ports:
      - name: ssh
        port: 2222
        targetPort: 22
        protocol: TCP
      externalIPs:
      - [your public IP]
