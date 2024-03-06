import { NextPage } from "next";
import { useAccount } from "wagmi";
import { MetaHeader } from "~~/components/MetaHeader";
import { MintStevey } from "~~/components/steveywonder";
import { SteveyWonderCard } from "~~/components/steveywonder/main/SteveyWonderCard";
import { useScaffoldContractRead } from "~~/hooks/scaffold-eth";

const SteveyWonder: NextPage = () => {
	const { address } = useAccount();

	const { data: balanceOfStevey, isLoading } = useScaffoldContractRead({
		contractName: "SteveyWonder",
		functionName: "balanceOf",
		args: [address],
	});

	return (
		<>
			<MetaHeader title="SteveyWonder" />
			{isLoading ? (
				<div className="flex flex-col flex-1 items-center justify-center">
					<span className="loading loading-bars loading-lg"></span>
				</div>
			) : Number(balanceOfStevey) > 0 ? (
				<div className="flex flex-col my-6 p-2 gap-y-8">
					<div className="flex flex-row flex-1 justify-between items-center px-10 py-2 md:px-20 lg:px-30">
						<span className="text-2xl font-medium">Your SteveyWonder NFTs</span>
						<MintStevey name="Mint" className="text-lg py-2" />
					</div>
					<div className="max-w-fit px-14 space-y-5 md:grid md:space-y-0 md:grid-cols-2 md:px-24 md:gap-10 lg:grid-cols-3 lg:px-36 xl:grid-cols-4">
						{[...Array(Number(balanceOfStevey))].map((_, index) => {
							console.log("id:", index);
							return <SteveyWonderCard id={BigInt(index)} key={index} />;
						})}
					</div>
				</div>
			) : (
				<div className="flex flex-col flex-1 items-center justify-center gap-6">
					<div className="text-2xl">No Stevey Wonder!</div>
					<MintStevey name="Mint Stevey Wonder" className="text-xl" />
				</div>
			)}
		</>
	);
};

export default SteveyWonder;
