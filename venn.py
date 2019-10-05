"""Generate necessary venn diagrams"""

import matplotlib

matplotlib.use("Agg")

# pylint: disable=wrong-import-position
from matplotlib import pyplot as plt
from matplotlib_venn import venn2


def venn_package():
    """Create a Packaing / Dependency Management venn diagram"""
    plt.clf()
    diagram = venn2(
        subsets={"01": 2, "10": 2, "11": 1},
        set_labels=("Packaging", "Dependency\nManagement"),
    )
    diagram.get_label_by_id("10").set_text(
        """
setuptools
twine
setup.py
setup.cfg
MANIFEST.in
""".strip()
    )
    diagram.get_label_by_id("01").set_text(
        """
pip
requirements.txt
pipenv
Pipfile
conda
pip-tools
""".strip()
    )
    diagram.get_label_by_id("11").set_text(
        """
poetry
pyproject.toml
""".strip()
    )
    plt.savefig(
        "img/venn_packaging.svg", bbox_inches=None, transparent=True
    )
    plt.clf()


if __name__ == "__main__":
    venn_package()
