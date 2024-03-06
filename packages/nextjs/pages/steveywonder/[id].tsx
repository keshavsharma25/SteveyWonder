import { ShowSteveyWonder } from "~~/components/steveywonder/main/ShowSteveyWonder";
import { useEffect } from "react";
import { useTokenURI } from "~~/hooks/steveywonder/useTokenURI";

const SteveyWonderId = () => {
	const { tokenURI } = useTokenURI({
		contractName: "SteveyWonder",
		tokenId: BigInt(1),
	});

	useEffect(() => {
		console.log(tokenURI);
	}, [tokenURI]);

	return (
		<section className="flex flex-1 justify-center">
			<div className="flex">
				<ShowSteveyWonder
					data={`data:image/svg+xml;base64,${tokenURI}`}
					width={518}
					height={607}
				/>
			</div>
		</section>
	);
};

export default SteveyWonderId;
