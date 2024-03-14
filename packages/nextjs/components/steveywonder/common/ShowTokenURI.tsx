import { useEffect, useState } from "react";
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
  const [isLoading, setIsLoading] = useState<boolean>(true);

  const { tokenURI } = useTokenURI({
    contractName,
    tokenId,
  });

  useEffect(() => {
    if (!tokenURI) {
      setIsLoading(true);
      return;
    }
    setIsLoading(false);
  }, [tokenURI]);

  return isLoading ? (
    <div className="bg-[#161728] animate-pulse w-[21.25rem] h-[21.25rem]"></div>
  ) : (
    <Image src={`data:image/svg+xml;base64,${tokenURI}`} alt="SteveyWonder Token" width={width} height={height} />
  );
};
