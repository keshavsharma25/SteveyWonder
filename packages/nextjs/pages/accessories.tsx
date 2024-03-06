import Image from "next/image";
import { NextPage } from "next";
import { MintAccs } from "~~/components/accessories/MintAccs";
import { ContractName } from "~~/utils/scaffold-eth/contract";

type Accessory = {
	title: Exclude<ContractName, "SteveyWonder" | "Account" | "ERC6551Registry">;
	imagePath: string;
};

const accessories: Accessory[] = [
	{
		title: "TShirt",
		imagePath: "tshirt.png",
	},
	{
		title: "Pants",
		imagePath: "pants.png",
	},
	{
		title: "Shoes",
		imagePath: "shoes.png",
	},
	{
		title: "Hairs",
		imagePath: "hairs.png",
	},
	{
		title: "Glasses",
		imagePath: "glasses.png",
	},
];

const Accessories: NextPage = () => {
	return (
		<div className="mx-[5rem] my-[4.5rem]">
			<h1 className="font-bold text-4xl pb-8">Accessories</h1>
			<div className="grid grid-cols-4 gap-y-16">
				{accessories.map(({ title, imagePath }) => (
					<div
						key={title}
						className="max-w-[20rem] max-h-[23rem] rounded-xl bg-[#161829] border border-gray-100 border-opacity-5"
					>
						<div className="relative mx-3 mt-3">
							<Image
								src={`/images/accessories/${imagePath}`}
								alt={title}
								width={300}
								height={300}
							/>
						</div>
						<div className="flex flex-row justify-between mx-8 my-5">
							<div className="text-2xl font-semibold">{title}</div>
							<MintAccs
								contractName={title}
								name="Mint"
								tokenId={BigInt(1)}
								key={title}
							/>
						</div>
					</div>
				))}
			</div>
		</div>
	);
};

export default Accessories;
