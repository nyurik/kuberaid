# kuberaid
A docker image to initialize RAID array of local SSDs on a Google Cloud's Kubernetes platform.

This image must be used with the `--privileged` flag (`securityContext: { privileged: true }` in Kubernetes pod definition)

The [init_raid.sh](./init_raid.sh) script un-mounts all ssd0, ssd1, ..., removes empty `/mnt/disks/ssd*` directories,
and creates the RAID array as described in the [Google's Local SSDs docs](https://cloud.google.com/kubernetes-engine/docs/how-to/persistent-volumes/local-ssd)

The image is based on the Google's [startup-script image](https://console.cloud.google.com/gcr/images/google-containers/GLOBAL/startup-script).
