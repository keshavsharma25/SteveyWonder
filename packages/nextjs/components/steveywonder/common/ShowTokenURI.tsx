import Image from "next/image";
import { useTokenURI } from "~~/hooks/steveywonder/useTokenURI";
import { ContractName } from "~~/utils/scaffold-eth/contract";

type Props = {
  contractName: ContractName;
  tokenId: bigint;
  width: number;
  height: number;
};

export const ShowTokenURI = ({ contractName, tokenId, width, height }: Props) => {
  const { tokenURI, isLoading } = useTokenURI({
    contractName,
    tokenId,
  });

  return isLoading ? (
    <span className="loading loading-bars loading-lg"></span>
  ) : (
    <Image src={`data:image/svg+xml;base64,${tokenURI}`} alt="SteveyWonder Token" width={width} height={height} />
  );
};
