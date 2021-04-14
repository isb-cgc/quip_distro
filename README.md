## >>> NOTE: isb-cgc uses the isb-cgc-webapp branch.

QuIP is a web accessible toolset designed to support analysis, management, and exploration of whole slide tissue images for cancer research. The QuIP system consists of a set of docker containers, which provide analysis execution and data management backend services, and web applications to load and visualize whole slide tissue images (in [OpenSlide](http://openslide.org) supported formats), run nuclear segmentation analyses on image tiles, and visualize and explore the analysis results. 

#     Launching a CaMicroscope viewer VM for the isb-cgc webapp.

The isb-cgc web app wraps camicroscope in an iframe. There are four VMs, each running camicroscope for different purposes.
These VMs are named "camic-viewer-xxx" where xxx is one of prod, dev, test or uat.

To configure and launch such a VM, execute:

    build/buildVM.sh <VM type>

where `<VM type>` is one of prod, dev, test, or uat.

This script will first create a static external IP address, also called camic-viewer-xxx, if such a IP address does not already exist. It will then delete any existing VM having that name and launch a new suitably configured VM. It will then scp copy and execute build/install_deps.sh on the new VM. install_deps.sh installs git and docker, performs apt-get update/upgrade and reboots the VM.

On rebooting, startup.sh script calls run_viewer.sh, which, in turn, pulls a docker container from GCR. The docker image includes the caMicroscope repo. Thus, if a change is made to the caMicroscope repo, the docker container must be reboot and pushed to GCR. Note that there is a separate GCR for each of the projects (isb-cgc, isb-cgc-test, isb-cgc-uat).

Note that subsequent discussion applies to the master full QuIP implementation.



