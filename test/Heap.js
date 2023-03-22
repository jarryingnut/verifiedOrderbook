const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const chance = require("chance").Chance();
const { expect } = require("chai");

const deployHeapFixture = async () => {
	// function getRandomNumber() {
	// 	return Math.floor(Math.random() * 50000) + 1;
	// }

	function isMaxHeap(heap) {
		length = heap.length;

		for (i = 0; i < length / 2; i++) {
			if (2 * i + 1 < length) {
				if (heap[2 * i + 1] > heap[i]) return false;
			}

			if (2 * i + 2 < length) {
				if (heap[2 * i + 2] > heap[i]) return false;
			}
			return true;
		}
	}

	async function insertNodes(numOfNodes) {
		for (let i = 0; i < numOfNodes; i++) {
			await heap.insert(chance.integer({ min: 1, max: 100000 }));
		}
	}

	const Heap = await ethers.getContractFactory("Heap");
	const heap = await Heap.deploy();

	return {
		heap,
		insertNodes,
		isMaxHeap,
	};
};

describe("Deployment", function () {
	it("Can deploy Heap Contract", async () => {
		const Heap = await ethers.getContractFactory("Heap");
		const heap = await Heap.deploy();
		expect(ethers.utils.isAddress(heap.address)).to.be.true;
	});
});

describe("insertion", function () {
	it("can insert 10 nodes", async () => {
		const { heap, isMaxHeap, insertNodes } = await loadFixture(
			deployHeapFixture
		);
		await insertNodes(10);
		const arr = await heap.getOrderbook();
		expect(isMaxHeap(arr)).to.be.true;
	});

	it("can insert 100 nodes", async () => {
		const { heap, isMaxHeap, insertNodes } = await loadFixture(
			deployHeapFixture
		);
		await insertNodes(100);
		const arr = await heap.getOrderbook();
		expect(isMaxHeap(arr)).to.be.true;
	});

	it("can insert 1000 nodes", async () => {
		const { heap, isMaxHeap, insertNodes } = await loadFixture(
			deployHeapFixture
		);
		await insertNodes(1000);
		const arr = await heap.getOrderbook();
		expect(isMaxHeap(arr)).to.be.true;
	});
});

describe("removeMax", function () {
	it("on inserting 10 nodes", async () => {
		const { heap, isMaxHeap, insertNodes } = await loadFixture(
			deployHeapFixture
		);
		await insertNodes(10);
		const max = parseInt(await heap.getMax());
		await expect(heap.removeMax())
			.to.emit(heap, "removeMaxEvent")
			.withArgs(max);

		await heap.removeMax();
		const arr = await heap.getOrderbook();
		expect(isMaxHeap(arr)).to.be.true;
	});

	it("on inserting 100 nodes", async () => {
		const { heap, isMaxHeap, insertNodes } = await loadFixture(
			deployHeapFixture
		);
		await insertNodes(100);
		const max = parseInt(await heap.getMax());
		await expect(heap.removeMax())
			.to.emit(heap, "removeMaxEvent")
			.withArgs(max);

		await heap.removeMax();
		const arr = await heap.getOrderbook();
		expect(isMaxHeap(arr)).to.be.true;
	});

	it("on inserting 1000 nodes", async () => {
		const { heap, isMaxHeap, insertNodes } = await loadFixture(
			deployHeapFixture
		);
		await insertNodes(1000);
		const max = parseInt(await heap.getMax());
		await expect(heap.removeMax())
			.to.emit(heap, "removeMaxEvent")
			.withArgs(max);

		await heap.removeMax();
		const arr = await heap.getOrderbook();
		expect(isMaxHeap(arr)).to.be.true;
	});
});

describe("removeMin", function () {
	it("on inserting 10 nodes", async () => {
		const { heap, isMaxHeap, insertNodes } = await loadFixture(
			deployHeapFixture
		);
		await insertNodes(10);
		const min = parseInt(await heap.getMin());
		await expect(heap.removeMin())
			.to.emit(heap, "removeMinEvent")
			.withArgs(min);

		await heap.removeMin();
		const arr = await heap.getOrderbook();
		expect(isMaxHeap(arr)).to.be.true;
	});

	it("on inserting 100 nodes", async () => {
		const { heap, isMaxHeap, insertNodes } = await loadFixture(
			deployHeapFixture
		);
		await insertNodes(100);
		const min = parseInt(await heap.getMin());
		await expect(heap.removeMin())
			.to.emit(heap, "removeMinEvent")
			.withArgs(min);

		await heap.removeMin();
		const arr = await heap.getOrderbook();
		expect(isMaxHeap(arr)).to.be.true;
	});

	it("on inserting 1000 nodes", async () => {
		const { heap, isMaxHeap, insertNodes } = await loadFixture(
			deployHeapFixture
		);
		await insertNodes(1000);
		const min = parseInt(await heap.getMin());
		await expect(heap.removeMin())
			.to.emit(heap, "removeMinEvent")
			.withArgs(min);

		await heap.removeMin();
		const arr = await heap.getOrderbook();
		expect(isMaxHeap(arr)).to.be.true;
	});
});
